require 'net/http'

class ContentTypeChecker
  UNKNOWN_CONTENT_TYPE_RESPONSE = { 'content-type' => 'unknown' }
  FILE_NOT_FOUND_RESPONSE = nil

  def initialize(asset_url)
    @asset_url = asset_url
  end

  def found?
    head.present?
  end

  def valid_content_type?
    actual_content_type == expected_content_type
  end

  def actual_content_type
    if head.present?
      head['content-type']
    else
      'not-found'
    end
  end

  private

  def clean_uri
    @clean_uri ||= URI.parse(URI.escape(@asset_url))
  end

  def head_options
    @head_options ||= { use_ssl: clean_uri.scheme == 'https', read_timeout: 3 }
  end

  def head
    @response ||= begin
      response = Net::HTTP.start(clean_uri.host, clean_uri.port, head_options) do |http|
        http.head(clean_uri.path)
      end

      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        response
      when Net::HTTPClientError
        FILE_NOT_FOUND_RESPONSE
      else
        UNKNOWN_CONTENT_TYPE_RESPONSE
      end
    end
  end

  def expected_content_type
    @expected_content_type ||= case File.extname(@asset_url).sub(/^\./, '')
                               when 'mp4', 'm4v', 'mov'
                                 'video/mp4'
                               when 'webm'
                                 'video/webm'
                               when 'ogv', 'ogg'
                                 'video/ogg'
                               else
                                 'unknown'
                               end
  end

end
