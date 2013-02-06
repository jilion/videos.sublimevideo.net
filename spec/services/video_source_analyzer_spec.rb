require 'fast_spec_helper'

require 'services/video_source_analyzer'

describe VideoSourceAnalyzer do
  let(:other_video_source) { OpenStruct.new(url: 'http://standard.com/video.mp4') }
  let(:vimeo_video_source) { OpenStruct.new(url: 'http://player.vimeo.com/external/49154845.sd.mp4?s=f10c9e0acaf7cb38e9a5539c6fbcb4ac') }

  context "with normal video sources" do
    subject { VideoSourceAnalyzer.new(other_video_source) }

    its(:origin) { should eq 'other' }
    its(:id) { should be_nil }
  end

  context "with Vimeo video sources" do
    subject { VideoSourceAnalyzer.new(vimeo_video_source) }

    its(:origin) { should eq 'vimeo' }
    its(:id) { should eq '49154845' }
  end

  context "with nil source" do
    subject { VideoSourceAnalyzer.new(nil) }

    its(:origin) { should eq 'other' }
    its(:id) { should be_nil }
  end
end
