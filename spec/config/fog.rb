require 'fog'

RSpec.configure do |config|
  config.before :each, fog_mock: true do
    set_fog_mock
  end
end

def set_fog_mock
  Fog::Mock.reset
  Fog.mock!
  Fog.credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
    region:                'us-east-1'
  }
  $fog_connection = Fog::Storage.new(provider: 'AWS')
  $fog_connection.directories.create(key: ENV['S3_BUCKET'])
end
