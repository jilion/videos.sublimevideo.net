require 's3_wrapper'
require 'autoembed_file'

class AutoEmbedFileManager
  attr_reader :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def upload
    data = autoembed_file.read
    S3Wrapper.put_object(s3_bucket, path, data, s3_headers)
  end

  private

  def autoembed_file
    AutoEmbedFile.new(video_tag)
  end

  def path
    "e/#{video_tag.site_token}/#{video_tag.uid}.html"
  end

  def s3_bucket
    S3Wrapper.buckets['sublimevideo']
  end

  def s3_headers
    {
      'Cache-Control' => 's-maxage=300, max-age=120, public', # 5 minutes / 2 minutes
      'Content-Type'  => 'text/html',
      'x-amz-acl'     => 'public-read'
    }
  end
end
