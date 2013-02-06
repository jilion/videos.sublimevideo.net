class VideoSourceAnalyzer
  VIMEO_URL_PART = 'player.vimeo.com/external'

  attr_reader :source

  def initialize(source)
    @source = source
  end

  def origin
    @origin ||=
      case url
      when %r{#{VIMEO_URL_PART}} then 'vimeo'
      else; 'other'
      end
  end

  def id
    @id ||=
      case origin
      when 'vimeo' then url.match(%r{//#{VIMEO_URL_PART}/(\d+)\..*})[1]
      else; nil
      end
  end

  private

  def url
    source && source.url
  end
end
