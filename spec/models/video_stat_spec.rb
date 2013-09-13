require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'video_stat'

describe VideoStat do
  let(:site_token) { 'site_token' }
  let(:video_uid)  { 'video_uid' }
  let(:video_tag)  { double('VideoTag', site_token: site_token, uid: video_uid) }

  describe ".last_days_starts" do
    before {
      stub_api_for(VideoStat) do |stub|
        stub.get("/private_api/sites/#{site_token}/videos/#{video_uid}/video_stats/last_days_starts?days=2") { |env| [200, {}, { starts: [42, 2] }.to_json] }
      end
    }

    it "returns starts array" do
      VideoStat.last_days_starts(video_tag, 2).should eq [42, 2]
    end
  end
end

