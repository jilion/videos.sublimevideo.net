require 'fast_spec_helper'

require 'video_source_analyzer'

describe VideoSourceAnalyzer do
  subject { VideoSourceAnalyzer.new(video_source) }

  context "with normal video sources" do
    let(:video_source) { OpenStruct.new(url: 'http://standard.com/video.mp4') }

    its(:origin) { should eq 'other' }
    its(:id) { should be_nil }
  end

  context "with Vimeo video sources" do
    let(:video_source) { OpenStruct.new(url: 'http://player.vimeo.com/external/49154845.sd.mp4?s=f10c9e0acaf7cb38e9a5539c6fbcb4ac') }

    its(:origin) { should eq 'vimeo' }
    its(:id) { should eq '49154845' }
  end

  context "with Vimeo video sources (with ,)" do
    let(:video_source) { OpenStruct.new(url: 'https://player.vimeo.com/external/46367971,sd.mp4?s=7b7502b21af6745b61cce486f5f9f825') }

    its(:origin) { should eq 'vimeo' }
    its(:id) { should eq '46367971' }
  end

  context "with nil source" do
    let(:video_source) { nil }

    its(:origin) { should eq 'other' }
    its(:id) { should be_nil }
  end
end
