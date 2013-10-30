require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_tag_starts_updater_worker'
require 'video_tag_starts_updater'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagStartsUpdaterWorker do
  let(:worker) { VideoTagStartsUpdaterWorker.new }

  it "delays job in videos queue" do
    expect(VideoTagStartsUpdaterWorker.sidekiq_options_hash['queue']).to eq 'videos'
  end

  describe ".perform" do
    let(:updater) { double(VideoTagStartsUpdater) }
    let(:video_tag) { double(VideoTag, id: 1) }

    it "updates video_tag starts" do
      expect(VideoTag).to receive(:find).with(video_tag.id) { video_tag }
      expect(VideoTagStartsUpdater).to receive(:new).with(video_tag) { updater }
      expect(updater).to receive(:update)
      worker.perform(video_tag.id)
    end
  end
end
