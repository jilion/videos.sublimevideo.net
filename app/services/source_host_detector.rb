require 'addressable/uri'

class SourceHostDetector
  attr_accessor :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def hosted_by
    case video_tag.try(:sources_origin)
    when 'youtube' then 'YouTube'
    when 'vimeo' then 'Vimeo'
    else _first_source_host
    end
  end

  private

  def _first_source_host
    uri = Addressable::URI.parse(video_tag.first_source.try(:url))
    uri.try(:host)
  end

end
