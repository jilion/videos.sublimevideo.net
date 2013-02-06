require 'fast_spec_helper'
require 'sidekiq'
require 'sidekiq/testing'

require 'workers/video_tag_updater_worker'
require 'services/video_tag_data_unaliaser'
require 'services/video_tag_updater'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagUpdaterWorker do
  let(:data) { { t: 'video title' } }
  let(:unaliases_data) { { title: 'video title' } }
  let(:params) { ['site_token', 'uid', data] }
  let(:video_tag) { mock(VideoTag) }
  before {
    VideoTagDataUnaliaser.stub(:unalias) { unaliases_data }
    VideoTag.stub(:find_or_initialize) { video_tag }
    VideoTagUpdater.stub_chain(:new, :update)
    Librato.stub(:increment)
  }

  it "performs async job" do
    expect {
      VideoTagUpdaterWorker.perform_async(*params)
    }.to change(VideoTagUpdaterWorker.jobs, :size).by(1)
  end

  it "delays job in videos queue" do
    VideoTagUpdaterWorker.sidekiq_options['queue'].should eq 'videos'
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

  it "increments Librato 'video_tag.update' metric" do
    Librato.should_receive(:increment).once.with('video_tag.update')
    VideoTagUpdaterWorker.new.perform(*params)
  end
end
