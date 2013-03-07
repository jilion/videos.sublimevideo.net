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
    aws_access_key_id:     S3Wrapper.access_key_id,
    aws_secret_access_key: S3Wrapper.secret_access_key,
    region:                'us-east-1'
  }
  $fog_connection = Fog::Storage.new(provider: 'AWS')
  S3Wrapper.buckets.each do |bucket_name, bucket|
    $fog_connection.directories.create(key: bucket)
  end
end
