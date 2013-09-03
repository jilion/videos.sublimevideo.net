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
        video_tag.should_receive(:attributes=).with(sources_id: nil, sources_origin: nil)
        updater.update(attributes)
      end

      it "sets sources_id and sources_origin from VideoSourceAnalyzer if not already set" do
        video_tag.should_receive(:first_source) { video_source }
        VideoSourceAnalyzer.should_receive(:new).with(video_source) { double(id: 'id', origin: 'source_origin') }
        video_tag.should_receive(:sources_id=).with('id')
        video_tag.should_receive(:sources_origin=).with('source_origin')
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
        VideoTagTitleFetcher.should_receive(:new).with(
          title: 'title',
          title_origin: 'title_origin',
          sources_id: 'sources_id',
          sources_origin: 'sources_origin') {  double(title: 'title', origin: 'title_origin') }
        video_tag.should_receive(:title=).with('title')
        video_tag.should_receive(:title_origin=).with('title_origin')
        updater.update(attributes)
      end

      it "sets loaded_at" do
        video_tag.should_receive(:loaded_at=).with(kind_of(Time))
        updater.update(attributes)
      end

      it "saves video_tag" do
        video_tag.should_receive(:save)
        updater.update(attributes)
      end
    end

    context "with sources_id & sources_origin attributes" do
      let(:attributes) { { sources_id: 'new_id', sources_origin: 'new_origin' } }

      it "merges default_attributes with attributes" do
        video_tag.should_receive(:attributes=).with(attributes)
        updater.update(attributes)
      end

      it "doesnt' set sources_id and sources_origin from VideoSourceAnalyzer if already set" do
        video_tag.stub(:sources_id) { 'id' }
        video_tag.stub(:sources_origin) { 'source_origin' }
        video_tag.should_not_receive(:sources_id=)
        video_tag.should_not_receive(:sources_origin=)
        updater.update(attributes)
      end
    end
  end
end
