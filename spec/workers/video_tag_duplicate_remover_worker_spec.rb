require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_tag_duplicate_remover_worker'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagDuplicateRemoverWorker do
  let(:params) { ['site_token', 'uid'] }
  let(:video_tag) { double(VideoTag) }
  before {
    VideoTag.stub_chain(:where, :first) { video_tag }
    VideoTagDuplicateRemover.stub_chain(:new, :remove_duplicate)
    Librato.stub(:increment)
  }

  it "performs async job" do
    expect {
      VideoTagDuplicateRemoverWorker.perform_async(*params)
    }.to change(VideoTagDuplicateRemoverWorker.jobs, :size).by(1)
  end

  it "delays job in videos queue" do
    VideoTagDuplicateRemoverWorker.sidekiq_options_hash['queue'].should eq 'videos-low'
  end

  it "finds video_tag" do
    VideoTag.should_receive(:where) { |mock|
      mock.should_receive(:first) { video_tag }
      mock
    }
    VideoTagDuplicateRemoverWorker.new.perform(*params)
  end

  it "removes duplicate video_tag" do
    VideoTagDuplicateRemover.should_receive(:new).with(video_tag) { |mock|
      mock.should_receive(:remove_duplicate)
      mock
    }
    VideoTagDuplicateRemoverWorker.new.perform(*params)
  end

  it "increments Librato 'video_tag.remove_duplicate' metric" do
    Librato.should_receive(:increment).once.with('video_tag.remove_duplicate')
    VideoTagDuplicateRemoverWorker.new.perform(*params)
  end

  describe ".perform_async_if_needed" do
    let(:video_tag) { double(VideoTag,
      site_token: 'site_token',
      uid: 'uid',
      saved_once?: true,
      valid_uid?: true
    ) }

    it "performs async only if video_tag are saved once" do
      VideoTagDuplicateRemoverWorker.should_receive(:perform_async)
      VideoTagDuplicateRemoverWorker.perform_async_if_needed(video_tag)
    end

    it "doesn't performs async if video_tag aren't saved once" do
      video_tag.stub(:saved_once?) { false }
      VideoTagDuplicateRemoverWorker.should_not_receive(:perform_async)
      VideoTagDuplicateRemoverWorker.perform_async_if_needed(video_tag)
    end

    it "performs async only if video_tag has a valid uid" do
      VideoTagDuplicateRemoverWorker.should_receive(:perform_async)
      VideoTagDuplicateRemoverWorker.perform_async_if_needed(video_tag)
    end

    it "doesn't performs async if video_tag hasn't a valid uid" do
      video_tag.stub(:valid_uid?) { false }
      VideoTagDuplicateRemoverWorker.should_not_receive(:perform_async)
      VideoTagDuplicateRemoverWorker.perform_async_if_needed(video_tag)
    end
  end
end
