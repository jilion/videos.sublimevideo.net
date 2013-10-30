require 'fast_spec_helper'

require 's3_wrapper'

describe S3Wrapper do

  describe ".put_object" do
    let(:fog_connection_mock) { double('fog_connection') }
    before { S3Wrapper.stub(:fog_connection) { fog_connection_mock } }

    it "delegates to fog_connection" do
      expect(fog_connection_mock).to receive(:put_object)
      S3Wrapper.put_object
    end
  end

end
