class VideoTagUpdater
  attr_reader :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def update(attributes)
    video_tag.attributes = default_attributes.merge(attributes)
    set_sources_id_and_sources_origin
    set_title_and_title_origin
    video_tag.save
  end

  private

  def default_attributes
    { sources_id: nil, sources_origin: nil }
  end

  def set_sources_id_and_sources_origin
    source = video_tag.first_source
    VideoSourceAnalyzer.new(source).tap do |sources_analyzer|
      video_tag.sources_id     ||= sources_analyzer.id
      video_tag.sources_origin ||= sources_analyzer.origin
    end
  end

  def set_title_and_title_origin
    attrs = video_tag.attributes.slice(*%w[title title_origin sources_id sources_origin])
    VideoTagTitleFetcher.new(attrs.symbolize_keys).tap do |title_fetcher|
      video_tag.title        = title_fetcher.title
      video_tag.title_origin = title_fetcher.origin
    end
  end
end
