require 'fog'
require 'configurator'

module S3Wrapper
  include Configurator

  config_file 's3.yml'
  config_accessor :access_key_id, :secret_access_key, :buckets

  def self.put_object(*attrs)
    self.fog_connection.put_object(*attrs)
  end

  def self.get_object(*attrs)
    self.fog_connection.get_object(*attrs)
  end

  private

  def self.fog_connection
    @fog_connection ||= Fog::Storage.new(
      provider:              'AWS',
      aws_access_key_id:     access_key_id,
      aws_secret_access_key: secret_access_key,
      region:                'us-east-1'
    )
  end
end
