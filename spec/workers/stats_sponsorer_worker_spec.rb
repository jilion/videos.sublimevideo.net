require 'fast_spec_helper'
require 'config/sidekiq'

require 'stats_sponsorer_worker'

describe StatsSponsorerWorker do

  it "performs async job" do
    expect {
      StatsSponsorerWorker.perform_async('site_token')
    }.to change(StatsSponsorerWorker.jobs, :size).by(1)
  end

  it "delays job in low (mysv) queue" do
    expect(StatsSponsorerWorker.sidekiq_options_hash['queue']).to eq 'my-low'
  end

  describe ".perform_async_if_needed" do
    let(:video_tag) { double('VideoTag',
      site_token: 'site_token',
      sources: [video_source]
    ) }

    context "with normal video sources" do
      let(:video_source) { OpenStruct.new(url: 'http://standard.com/video.mp4') }

      it "does not sponsor stats" do
        expect(StatsSponsorerWorker).to_not receive(:perform_async)
        StatsSponsorerWorker.perform_async_if_needed(video_tag)
      end
    end

    context "with dmcloud.net video sources" do
      let(:video_source) { OpenStruct.new(url: 'http://cdn.dmcloud.net/video.mp4') }

      it "sponsors stats" do
        expect(StatsSponsorerWorker).to receive(:perform_async).with('site_token')
        StatsSponsorerWorker.perform_async_if_needed(video_tag)
      end
    end

    context "with dailymotion.com video sources" do
      let(:video_source) { OpenStruct.new(url: 'http://dailymotion.com/video.mp4') }

      it "sponsors stats" do
        expect(StatsSponsorerWorker).to receive(:perform_async).with('site_token')
        StatsSponsorerWorker.perform_async_if_needed(video_tag)
      end
    end
  end

end
