require 'fast_spec_helper'

require 'video_info_wrapper'

describe VideoInfoWrapper do
  let(:video_info) { OpenStruct.new(title: 'video title') }
  before { Librato.stub(:increment) }

  describe "#title" do
    context "with Vimeo provider" do
      subject { VideoInfoWrapper.new(video_id: 'video_id', provider: 'vimeo') }

      context "with public video" do
        before { expect(VideoInfo).to receive(:new).with('http://vimeo.com/video_id') { video_info } }

        its(:title) { should eq 'video title' }
      end

      context "with private or invalid video" do
        before { expect(VideoInfo).to receive(:new).with('http://vimeo.com/video_id') { nil } }

        its(:title) { should be_nil }
      end
    end

    context "with YouTube provider" do
      subject { VideoInfoWrapper.new(video_id: 'video_id', provider: 'youtube') }

      context "with public video" do
        before { expect(VideoInfo).to receive(:new).with('http://www.youtube.com/watch?v=video_id') { video_info } }

        its(:title) { should eq 'video title' }
      end

      context "with private or invalid video" do
        before { expect(VideoInfo).to receive(:new).with('http://www.youtube.com/watch?v=video_id') { nil } }

        its(:title) { should be_nil }
      end
    end

    it "increments Librato 'video_info.call' metrics" do
      VideoInfo.stub(:new) { video_info }
      expect(Librato).to receive(:increment).with('video_info.call', source: 'provider')
      VideoInfoWrapper.new(provider: 'provider')
    end
  end
end
