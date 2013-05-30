require 'spec_helper'

describe VideoTagStatsUpdater do
  let(:updater) { VideoTagStatsUpdater.new(video_tag) }
  let(:starts_365) { 365.times.map { |i| i + 1 } }

  describe "#update" do
    let(:video_tag) { build(:video_tag) }
    before { VideoStat.stub(:last_day_starts) { starts_365 } }

    it "updates starts_updated_at" do
      video_tag.should_receive(:starts_updated_at=).with(kind_of(Time))
      updater.update
    end

    context "video_tag with starts_updated_at at nil" do
      let(:video_tag) { build(:video_tag, starts_updated_at: nil, updated_at: 23.hours.ago) }

      it "updates starts for last 365 days" do
        VideoStat.should_receive(:last_day_starts).with(video_tag.uid, 365) { starts_365 }
        updater.update
        updater.video_tag.starts.first.should eq 1
        updater.video_tag.starts.last.should eq 365
      end
    end

    context "video_tag with starts updated 2 days ago" do
      let(:video_tag) { build(:video_tag, starts_updated_at: 2.days.ago, updated_at: 23.hours.ago, starts: starts_365) }

      it "updates starts for last 1 day" do
        VideoStat.should_receive(:last_day_starts).with(video_tag.uid, 1) { [366] }
        updater.update
        updater.video_tag.starts.first.should eq 2
        updater.video_tag.starts.last.should eq 366
      end
    end

    context "video_tag with starts_updated_at and updated_at 3 days ago" do
      let(:time) { 3.days.ago }
      let(:video_tag) { build(:video_tag, starts_updated_at: time, updated_at: time, starts: starts_365) }

      it "updates starts for last 2 day" do
        VideoStat.should_not_receive(:last_day_starts)
        updater.update
        updater.video_tag.starts.first.should eq 3
        updater.video_tag.starts.last.should eq 0
      end
    end
  end

end
