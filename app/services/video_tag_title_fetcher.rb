require 'video_info_wrapper'

class VideoTagTitleFetcher
  attr_reader :video_title, :video_title_origin, :sources_id, :sources_origin

  def initialize(args)
    @video_title        = args[:title]
    @video_title_origin = args[:title_origin]
    @sources_id         = args[:sources_id]
    @sources_origin     = args[:sources_origin]
  end

  def title
    fetch
    @title
  end

  def origin
    fetch
    @origin
  end

  private

  def fetch
    return if fetched?
    if video_title_origin == 'source'
      @title = @origin = nil
    elsif video_title || video_title_origin
      @title = video_title
      @origin = video_title_origin || 'attribute'
    else
      fetch_from_sources
    end
  end

  def fetch_from_sources
    if sources_origin == 'other'
      @title = @origin = nil
    else
      VideoInfoWrapper.new(video_id: sources_id, provider: sources_origin).tap do |video_info|
        @title = video_info.title
        @origin = video_info.provider
      end
    end
  end

  def fetched?
    defined?(@origin) && defined?(@title)
  end

end
