require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_tag_start_handler_worker'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagStartHandlerWorker do
  let(:time) { Time.now.utc }
  let(:params) { ['site_token', 'uid', { 'vd' => '123456', 't' => time.to_s }] }
  let(:video_tags) { double(VideoTag, update_columns: true) }
  let(:worker) { VideoTagStartHandlerWorker.new }
  before {
    VideoTag.stub(:where) { video_tags }
  }

  it "performs async job" do
    expect {
      VideoTagStartHandlerWorker.perform_async(*params)
    }.to change(VideoTagStartHandlerWorker.jobs, :size).by(1)
  end

  it "delays job in videos queue" do
    expect(VideoTagStartHandlerWorker.sidekiq_options_hash['queue']).to eq 'videos'
  end

  it "updates video_tag duration" do
    expect(video_tags).to receive(:update_columns).with(started_at: Time.parse(time.to_s), duration: 123456)
    worker.perform(*params)
  end

  it "limits max duration integer" do
    params[2] = { 'vd' => '5461782000', 't' => time.to_s }
    expect(video_tags).to receive(:update_columns).with(started_at: Time.parse(time.to_s), duration: nil)
    worker.perform(*params)
  end
end
