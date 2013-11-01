require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'video_stat'

describe VideoStat do
  let(:site_token) { 'abcd1234' }
  let(:video_uid)  { 'video_uid' }
  let(:video_tag)  { double('VideoTag', site_token: site_token, uid: video_uid) }

  describe ".last_days_starts" do
    before {
      stub_api_for(VideoStat) do |stub|
        stub.get('/private_api/video_stats/last_days_starts?days=2&site_token=abcd1234&video_uid=video_uid') { |env| [200, {}, [42, 2].to_json] }
      end
    }

    it "returns starts array" do
      expect(VideoStat.last_days_starts(video_tag, 2)).to eq [42, 2]
    end
  end
end

