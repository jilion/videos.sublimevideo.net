require 'fast_spec_helper'
require 'config/sidekiq'

require 'video_source_content_type_checker_worker'

VideoSource = Class.new unless defined?(VideoSource)

describe VideoSourceContentTypeCheckerWorker do
  let(:video_source) { double(:video_source, id: 42, url: 'http://domain.com/video.mp4') }
  let(:content_type_checker) { double }
  let(:worker) { described_class.new }
  before do
    expect(VideoSource).to receive(:where).with(id: 42) { double(first: video_source) }
    Librato.stub(:increment)
  end

  describe '#perform' do
    before { expect(HttpContentType::Checker).to receive(:new).with(video_source.url) { content_type_checker } }

    context 'source has no issues' do
      it 'leaves the issues array empty' do
        expect(content_type_checker).to receive(:error?) { false }
        expect(content_type_checker).to receive(:found?) { true }
        expect(content_type_checker).to receive(:valid_content_type?) { true }
        expect(video_source).to receive(:issues=).with([])
        expect(video_source).to receive(:save)

        worker.perform(video_source.id)
      end
    end

    context 'source has an error' do
      it 'leaves the issues array empty' do
        expect(content_type_checker).to receive(:error?) { true }
        expect(video_source).to receive(:issues=).with([])
        expect(video_source).to receive(:save)

        worker.perform(video_source.id)
      end
    end

    context 'source cannot be found' do
      it 'adds "not-found" to the array' do
        expect(content_type_checker).to receive(:error?) { false }
        expect(content_type_checker).to receive(:found?) { false }
        expect(video_source).to receive(:issues=).with(['not-found'])
        expect(video_source).to receive(:save)

        worker.perform(video_source.id)
      end
    end

    context 'source has a wrong mime type' do
      it 'adds "content-type-error" to the array' do
        expect(content_type_checker).to receive(:error?) { false }
        expect(content_type_checker).to receive(:found?) { true }
        expect(content_type_checker).to receive(:valid_content_type?) { false }
        expect(video_source).to receive(:issues=).with(['content-type-error'])
        expect(video_source).to receive(:save)

        worker.perform(video_source.id)
      end
    end
  end

end
