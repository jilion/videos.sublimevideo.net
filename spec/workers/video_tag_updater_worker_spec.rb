require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_tag_updater_worker'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagUpdaterWorker do
  let(:data) { { t: 'video title' } }
  let(:unaliases_data) { { title: 'video title' } }
  let(:params) { ['site_token', 'uid', data] }
  let(:video_tag) { double(VideoTag) }
  before {
    VideoTagDataUnaliaser.stub(:unalias) { unaliases_data }
    VideoTag.stub(:find_or_initialize) { video_tag }
    VideoTagUpdater.stub_chain(:new, :update)
    VideoTagDuplicateRemoverWorker.stub(:perform_async_if_needed)
    AutoEmbedFileUploaderWorker.stub(:perform_async_if_needed)
    Librato.stub(:increment)
  }

  it "performs async job" do
    expect {
      VideoTagUpdaterWorker.perform_async(*params)
    }.to change(VideoTagUpdaterWorker.jobs, :size).by(1)
  end

  it "delays job in videos queue" do
    VideoTagUpdaterWorker.sidekiq_options_hash['queue'].should eq 'videos'
  end

  it "skips update if site_token is mysv token" do
    params[0] = SiteToken[:my]
    VideoTagDataUnaliaser.should_not_receive(:unalias)
    VideoTagUpdaterWorker.new.perform(*params)
  end

  it "unaliases aliased data" do
    VideoTagDataUnaliaser.should_receive(:unalias).with(data)
    VideoTagUpdaterWorker.new.perform(*params)
  end

  it "finds or initializes video_tag" do
    VideoTag.should_receive(:find_or_initialize).with(site_token: 'site_token', uid: 'uid')
    VideoTagUpdaterWorker.new.perform(*params)
  end

  it "updates video_tag" do
    VideoTagUpdater.should_receive(:new).with(video_tag) { |mock|
      mock.should_receive(:update).with(unaliases_data)
      mock
    }
    VideoTagUpdaterWorker.new.perform(*params)
  end

  it "removes duplicate video_tag if needed" do
    VideoTagDuplicateRemoverWorker.should_receive(:perform_async_if_needed).with(video_tag)
    VideoTagUpdaterWorker.new.perform(*params)
  end

  it "uploads video_tag autoembed if needed" do
    AutoEmbedFileUploaderWorker.should_receive(:perform_async_if_needed).with(video_tag)
    VideoTagUpdaterWorker.new.perform(*params)
  end

  it "increments Librato 'video_tag.update' metric" do
    Librato.should_receive(:increment).once.with('video_tag.update')
    VideoTagUpdaterWorker.new.perform(*params)
  end
end
