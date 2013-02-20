require 'video_info'
require 'librato-rails'

class VideoInfoWrapper
  attr_reader :video_id, :provider

  def initialize(args)
    @video_id = args[:video_id]
    @provider = args[:provider]
  end

  def title
    video_info && video_info.title
  end

  private

  def video_info
    Librato.increment('video_info.call', source: provider) unless @video_info
    @video_info ||= VideoInfo.get(url)
  end

  def url
    case provider
    when 'youtube' then "http://www.youtube.com/watch?v=#{video_id}"
    when 'vimeo' then "http://vimeo.com/#{video_id}"
    end
  end
end
