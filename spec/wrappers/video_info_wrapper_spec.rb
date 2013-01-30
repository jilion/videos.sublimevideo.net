require 'fast_spec_helper'
require 'video_info'
require 'wrappers/video_info_wrapper'

describe VideoInfoWrapper do
  let(:video_info) { OpenStruct.new(title: 'video title') }
  before { Librato.stub(:increment) }

  describe "#title" do
    context "with Vimeo provider" do
      let(:wrapper) { VideoInfoWrapper.new(video_id: 'video_id', provider: 'vimeo') }

      it "returns title for public video" do
        VideoInfo.should_receive(:get).with('http://vimeo.com/video_id') { video_info }
        wrapper.title.should eq 'video title'
      end

      it "returns nil for private or invalid video" do
        VideoInfo.should_receive(:get).with('http://vimeo.com/video_id') { nil }
        wrapper.title.should be_nil
      end
    end

    context "with YouTube provider" do
      let(:wrapper) { VideoInfoWrapper.new(video_id: 'video_id', provider: 'youtube') }

      it "returns title for public video" do
        VideoInfo.should_receive(:get).with('http://www.youtube.com/watch?v=video_id') { video_info }
        wrapper.title.should eq 'video title'
      end

      it "returns nil for private or invalid video" do
        VideoInfo.should_receive(:get).with('http://www.youtube.com/watch?v=video_id') { nil }
        wrapper.title.should be_nil
      end
    end

    it "increments Librato 'video_info.call' metrics once" do
      VideoInfo.stub(:get) { video_info }
      wrapper = VideoInfoWrapper.new(provider: 'provider')
      Librato.should_receive(:increment).once.with('video_info.call', source: 'provider')
      wrapper.title
      wrapper.title
    end
  end
end
