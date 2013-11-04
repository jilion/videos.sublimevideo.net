require 'fast_spec_helper'

require 'video_tag_updater'

describe VideoTagUpdater do
  let(:updater) { VideoTagUpdater.new(video_tag) }
  let(:video_tag) { OpenStruct.new(attributes: {}) }
  let(:video_source) { double('VideoSource') }
  before {
    VideoSourceAnalyzer.stub(:new) { double(id: 'id', origin: 'source_origin') }
    VideoTagTitleFetcher.stub(:new) { double(title: 'title', origin: 'title_origin') }
  }

  describe "#update" do
    context "with standard attributes" do
      let(:attributes) { {} }

      it "updates video_tag attributes with defaults" do
        expect(video_tag).to receive(:attributes=).with(sources_id: nil, sources_origin: nil)
        updater.update(attributes)
      end

      it "sets sources_id and sources_origin from VideoSourceAnalyzer if not already set" do
        expect(video_tag).to receive(:first_source) { video_source }
        expect(VideoSourceAnalyzer).to receive(:new).with(video_source) { double(id: 'id', origin: 'source_origin') }
        expect(video_tag).to receive(:sources_id=).with('id')
        expect(video_tag).to receive(:sources_origin=).with('source_origin')
        updater.update(attributes)
      end

      it "sets title & title_origin from VideoTagTitleFetcher" do
        video_tag.stub(:attributes) { {
          'title' => 'title',
          'title_origin' => 'title_origin',
          'sources_id' => 'sources_id',
          'sources_origin' => 'sources_origin',
          'other' => 'attributes'
        } }
        expect(VideoTagTitleFetcher).to receive(:new).with(
          title: 'title',
          title_origin: 'title_origin',
          sources_id: 'sources_id',
          sources_origin: 'sources_origin') {  double(title: 'title', origin: 'title_origin') }
        expect(video_tag).to receive(:title=).with('title')
        expect(video_tag).to receive(:title_origin=).with('title_origin')
        updater.update(attributes)
      end

      it "saves video_tag" do
        expect(video_tag).to receive(:save)
        updater.update(attributes)
      end
    end

    context "with sources_id & sources_origin attributes" do
      let(:attributes) { { sources_id: 'new_id', sources_origin: 'new_origin' } }

      it "merges default_attributes with attributes" do
        expect(video_tag).to receive(:attributes=).with(attributes)
        updater.update(attributes)
      end

      it "doesnt' set sources_id and sources_origin from VideoSourceAnalyzer if already set" do
        video_tag.stub(:sources_id) { 'id' }
        video_tag.stub(:sources_origin) { 'source_origin' }
        expect(video_tag).to_not receive(:sources_id=)
        expect(video_tag).to_not receive(:sources_origin=)
        updater.update(attributes)
      end
    end
  end
end
