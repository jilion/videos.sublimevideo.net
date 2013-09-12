require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_tag_duration_updater_worker'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagDurationUpdaterWorker do
  let(:params) { ['site_token', 'uid', '123456'] }
  let(:video_tags) { double(VideoTag, update_all: true) }
  let(:worker) { VideoTagDurationUpdaterWorker.new }
  before {
    VideoTag.stub(:where) { video_tags }
    Librato.stub(:increment)
  }

  it "performs async job" do
    expect {
      VideoTagDurationUpdaterWorker.perform_async(*params)
    }.to change(VideoTagDurationUpdaterWorker.jobs, :size).by(1)
  end

  it "delays job in videos queue" do
    VideoTagDurationUpdaterWorker.sidekiq_options_hash['queue'].should eq 'videos'
  end

  it "skips update if site_token is mysv token" do
    params[0] = SiteToken[:my]
    expect(VideoTag).to_not receive(:where)
    worker.perform(*params)
  end

  it "updates video_tag duration" do
    expect(video_tags).to receive(:update_all).with(duration: '123456')
    worker.perform(*params)
  end
end
