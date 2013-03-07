require 'fast_spec_helper'

require 's3_wrapper'

describe S3Wrapper do

  describe ".buckets" do
    it "returns bucket name" do
      S3Wrapper.buckets['sublimevideo'].should eq 'dev.sublimevideo'
    end
  end

  describe ".put_object" do
    let(:fog_connection_mock) { mock('fog_connection') }
    before { S3Wrapper.stub(:fog_connection) { fog_connection_mock } }

    it "delegates to fog_connection" do
      fog_connection_mock.should_receive(:put_object)
      S3Wrapper.put_object
    end
  end

end
