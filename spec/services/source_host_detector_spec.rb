require 'fast_spec_helper'

require 'services/source_host_detector'

describe SourceHostDetector do
  let(:video_tag) { double('VideoTag') }
  let(:detector) { SourceHostDetector.new(video_tag) }

  context "when source_origin is youtube" do
    before { video_tag.stub(:sources_origin) { 'youtube' } }

    it "returns YouTube" do
      expect(detector.hosted_by).to eq 'YouTube'
    end
  end

  context "when source_origin is vimeo" do
    before { video_tag.stub(:sources_origin) { 'vimeo' } }

    it "returns Vimeo" do
      expect(detector.hosted_by).to eq 'Vimeo'
    end
  end

  context "when source_origin is other" do
    before {
      video_tag.stub(:sources_origin) { 'other' }
      video_tag.stub(:first_source) { source }
    }

    context "when first sources url is hosted by video2.cdn.schooltube.com" do
      let(:source) { double('VideoSource', url: 'http://video2.cdn.schooltube.com/v/e2/73/41/91/b6/bc/e2734191-b6bc-436f-43b0-b3a86824753a.mp4?e=1354460955&h=ce0a65220879d745dbee68211752ea9c')}

      it "returns cdn.schooltube.com" do
        expect(detector.hosted_by).to eq 'video2.cdn.schooltube.com'
      end
    end
  end

end
