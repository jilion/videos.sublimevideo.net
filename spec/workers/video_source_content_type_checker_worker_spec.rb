require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_source_content_type_checker_worker'

VideoSource = Class.new unless defined?(VideoSource)

describe VideoSourceContentTypeCheckerWorker do
  let(:video_source) { double(:video_source, id: 42, url: 'http://domain.com/video.mp4') }
  let(:content_type_checker) { double }
  let(:worker) { described_class.new }
  before do
    VideoSource.should_receive(:where).with(id: 42) { double(first: video_source) }
    Librato.stub(:increment)
  end

  describe '#perform' do
    before { HttpContentType::Checker.should_receive(:new).with(video_source.url) { content_type_checker } }

    context 'source has no issues' do
      it 'leaves the issues array empty' do
        content_type_checker.should_receive(:found?) { true }
        content_type_checker.should_receive(:valid_content_type?) { true }
        video_source.should_receive(:issues=).with([])
        video_source.should_receive(:save)

        worker.perform(video_source.id)
      end
    end

    context 'source cannot be found' do
      it 'leaves the issues array empty' do
        content_type_checker.should_receive(:found?) { false }
        video_source.should_receive(:issues=).with(['not-found'])
        video_source.should_receive(:save)

        worker.perform(video_source.id)
      end
    end

    context 'source has a wrong mime type' do
      it 'leaves the issues array empty' do
        content_type_checker.should_receive(:found?) { true }
        content_type_checker.should_receive(:valid_content_type?) { false }
        video_source.should_receive(:issues=).with(['content-type-error'])
        video_source.should_receive(:save)

        worker.perform(video_source.id)
      end
    end
  end

end
