require 'spec_helper'

describe VideoTagStartsUpdater do
  let(:updater) { VideoTagStartsUpdater.new(video_tag) }
  let(:starts_365) { 365.times.map { |i| i + 1 } }

  describe "#update" do
    let(:video_tag) { create(:video_tag, started_at: 23.hours.ago) }
    before { VideoStat.stub(:last_days_starts) { starts_365 } }

    it "updates starts_updated_at" do
      expect(video_tag).to receive(:starts_updated_at=).with(kind_of(Time))
      updater.update
    end

    it "updates last x days starts counter" do
      updater.update
      expect(updater.video_tag.last_30_days_starts).to eq 10515
      expect(updater.video_tag.last_90_days_starts).to eq 28845
      expect(updater.video_tag.last_365_days_starts).to eq 66795
    end

    context "video_tag with starts_updated_at at nil" do
      let(:video_tag) { build(:video_tag, starts_updated_at: nil, started_at: 23.hours.ago) }

      it "updates starts for last 365 days" do
        expect(VideoStat).to receive(:last_days_starts).with(video_tag, 365) { starts_365 }
        updater.update
        expect(updater.video_tag.starts.first).to eq 1
        expect(updater.video_tag.starts.last).to eq 365
      end
    end

    context "video_tag with starts updated 1 days ago" do
      let(:video_tag) { build(:video_tag, starts_updated_at: 1.days.ago, started_at: 23.hours.ago, starts: starts_365) }

      it "updates starts for last 1 day" do
        expect(VideoStat).to receive(:last_days_starts).with(video_tag, 0) { [] }
        updater.update
        expect(updater.video_tag.starts.first).to eq 1
        expect(updater.video_tag.starts.last).to eq 365
      end
    end

    context "video_tag with starts updated 2 days ago" do
      let(:video_tag) { build(:video_tag, starts_updated_at: 2.days.ago, started_at: 23.hours.ago, starts: starts_365) }

      it "updates starts for last 1 day" do
        expect(VideoStat).to receive(:last_days_starts).with(video_tag, 1) { [366] }
        updater.update
        expect(updater.video_tag.starts.first).to eq 2
        expect(updater.video_tag.starts.last).to eq 366
      end
    end

    context "video_tag has not been loaded since last update" do
      let(:video_tag) { build(:video_tag, starts_updated_at: 3.days.ago, started_at: 4.days.ago, starts: starts_365) }

      it "updates starts for last 2 day" do
        expect(VideoStat).to_not receive(:last_days_starts)
        updater.update
        expect(updater.video_tag.starts.first).to eq 3
        expect(updater.video_tag.starts.last).to eq 0
      end
    end
  end

end
