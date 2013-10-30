require 'video_info'

class VideoInfoWrapper
  attr_reader :video_id, :provider, :video_info

  def initialize(args)
    @video_id = args[:video_id]
    @provider = args[:provider]
    @video_info = VideoInfo.new(_url)
    Librato.increment('video_info.call', source: provider)
  end

  def title
    video_info.title
  rescue
    nil
  end

  private

  def _url
    case provider
    when 'youtube' then "http://www.youtube.com/watch?v=#{video_id}"
    when 'vimeo' then "http://vimeo.com/#{video_id}"
    end
  end
end
