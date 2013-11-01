require 'fast_spec_helper'
require 'config/sidekiq'

require 'autoembed_file_uploader_worker'

VideoTag = Class.new unless defined?(VideoTag)

describe AutoEmbedFileUploaderWorker do
  let(:params) { ['site_token', 'uid'] }
  let(:video_tag) { double(VideoTag) }
  before {
    VideoTag.stub_chain(:where, :first) { video_tag }
    AutoEmbedFileManager.stub_chain(:new, :upload)
    Librato.stub(:increment)
  }

  it "performs async job" do
    expect {
      AutoEmbedFileUploaderWorker.perform_async(*params)
    }.to change(AutoEmbedFileUploaderWorker.jobs, :size).by(1)
  end

  it "delays job in videos queue" do
    expect(AutoEmbedFileUploaderWorker.sidekiq_options_hash['queue']).to eq 'videos'
  end

  it "finds video_tag" do
    expect(VideoTag).to receive(:where) { |mock|
      expect(mock).to receive(:first) { video_tag }
      mock
    }
    AutoEmbedFileUploaderWorker.new.perform(*params)
  end

  it "uplaods video_tag autoembed file" do
    expect(AutoEmbedFileManager).to receive(:new).with(video_tag) { |mock|
      expect(mock).to receive(:upload)
      mock
    }
    AutoEmbedFileUploaderWorker.new.perform(*params)
  end

  it "increments Librato 'video_tag.autoembed.uploads' metric" do
    expect(Librato).to receive(:increment).once.with('video_tag.autoembed.uploads')
    AutoEmbedFileUploaderWorker.new.perform(*params)
  end

  describe ".perform_async_if_needed" do
    let(:video_tag) { double(VideoTag,
      site_token: 'site_token',
      uid: 'uid',
      options: { "autoembed" => true }
    ) }

    it "performs async only if video_tag autoembed option is true" do
      expect(AutoEmbedFileUploaderWorker).to receive(:perform_async)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
    end

    it "doesn't performs async if video_tag autoembed option is false" do
      video_tag.stub(:options) { { "autoembed" => false } }
      expect(AutoEmbedFileUploaderWorker).to_not receive(:perform_async)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
    end

    it "doesn't performs async if video_tag options are nil" do
      video_tag.stub(:options) { nil }
      expect(AutoEmbedFileUploaderWorker).to_not receive(:perform_async)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
    end
  end
end
