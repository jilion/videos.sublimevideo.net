require 'spec_helper'

describe VideoTagStartsUpdaterManagerWorker do
  let(:worker) { VideoTagStartsUpdaterManagerWorker.new }

  it "delays job in videos queue" do
    expect(VideoTagStartsUpdaterManagerWorker.sidekiq_options_hash['queue']).to eq 'videos'
  end

  describe ".perform" do
    let!(:video_tag1) { create(:video_tag, starts_updated_at: nil, started_at: 1.day.ago) }
    let!(:video_tag2) { create(:video_tag, site_token: video_tag1.site_token, starts_updated_at: 1.day.ago) }
    let!(:video_tag3) { create(:video_tag, site_token: video_tag1.site_token, starts_updated_at: Time.now) }
    let!(:video_tag4) { create(:video_tag) }
    before {
      Site.stub(:tokens) { [video_tag1.site_token] }
      Rails.cache.write('update_starts_limit', 4)
    }

    it "updates video_tag starts" do
      expect(VideoTagStartsUpdaterWorker).to receive(:perform_in).with(kind_of(Integer), video_tag2.id).ordered
      expect(VideoTagStartsUpdaterWorker).to receive(:perform_in).with(kind_of(Integer), video_tag1.id).ordered
      worker.perform
    end
  end
end
