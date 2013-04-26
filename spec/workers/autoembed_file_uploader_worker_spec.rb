require 'fast_spec_helper'
require 'config/sidekiq'

require 'autoembed_file_uploader_worker'

VideoTag = Class.new unless defined?(VideoTag)

describe AutoEmbedFileUploaderWorker do
  let(:params) { ['site_token', 'uid'] }
  let(:video_tag) { mock(VideoTag) }
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
    AutoEmbedFileUploaderWorker.sidekiq_options_hash['queue'].should eq 'videos'
  end

  it "finds video_tag" do
    VideoTag.should_receive(:where) { |mock|
      mock.should_receive(:first) { video_tag }
      mock
    }
    AutoEmbedFileUploaderWorker.new.perform(*params)
  end

  it "uplaods video_tag autoembed file" do
    AutoEmbedFileManager.should_receive(:new).with(video_tag) { |mock|
      mock.should_receive(:upload)
      mock
    }
    AutoEmbedFileUploaderWorker.new.perform(*params)
  end

  it "increments Librato 'video_tag.remove_duplicate' metric" do
    Librato.should_receive(:increment).once.with('video_tag.autoembed.uploads')
    AutoEmbedFileUploaderWorker.new.perform(*params)
  end

  describe ".perform_async_if_needed" do
    let(:video_tag) { mock(VideoTag,
      site_token: 'site_token',
      uid: 'uid',
      options: { "autoembed" => true }
    ) }

    it "performs async only if video_tag autoembed option is true" do
      AutoEmbedFileUploaderWorker.should_receive(:perform_async)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
    end

    it "doesn't performs async if video_tag autoembed option is false" do
      video_tag.stub(:options) { { "autoembed" => false } }
      AutoEmbedFileUploaderWorker.should_not_receive(:perform_async)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
    end

    it "doesn't performs async if video_tag options are nil" do
      video_tag.stub(:options) { nil }
      AutoEmbedFileUploaderWorker.should_not_receive(:perform_async)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
    end
  end
end
