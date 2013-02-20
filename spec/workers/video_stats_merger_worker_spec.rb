require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_stats_merger_worker'

describe VideoStatsMergerWorker do

  it "performs async job" do
    expect {
      VideoStatsMergerWorker.perform_async('site_token', 'new_uid', 'old_uid')
    }.to change(VideoStatsMergerWorker.jobs, :size).by(1)
  end

  it "delays job in low (mysv) queue" do
    VideoStatsMergerWorker.sidekiq_options['queue'].should eq 'low'
  end
end
