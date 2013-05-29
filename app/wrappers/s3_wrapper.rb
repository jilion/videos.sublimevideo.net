require 'fog'

module S3Wrapper

  def self.put_object(*attrs)
    self.fog_connection.put_object(ENV['S3_BUCKET'], *attrs)
  end

  def self.get_object(*attrs)
    self.fog_connection.get_object(ENV['S3_BUCKET'], *attrs)
  end

  private

  def self.fog_connection
    @fog_connection ||= Fog::Storage.new(
      provider:              'AWS',
      aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
      region:                'us-east-1'
    )
  end
end
