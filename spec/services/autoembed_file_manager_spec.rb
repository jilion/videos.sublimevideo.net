require 'fast_spec_helper'
require 'config/fog'

require 'autoembed_file_manager'

describe AutoEmbedFileManager , :fog_mock do
  let(:s3_bucket) { S3Wrapper.buckets['sublimevideo'] }
  let(:path) { 'e/site_token/uid.html' }
  let(:video_tag) { mock('VideoTag',
    site_token: 'site_token',
    uid: 'uid',
  ) }
  let(:manager) { AutoEmbedFileManager.new(video_tag) }

  describe "#upload" do
    let(:autoembed_file) { Tempfile.new('autoembed_file') }
    before { AutoEmbedFile.stub(:new) { autoembed_file } }

    describe "S3 object" do
      before { manager.upload }

      describe "acl" do
        let(:acl) { S3Wrapper.fog_connection.get_object_acl(s3_bucket, path).body }

        it "is public" do
          acl['AccessControlList'].should include({"Permission"=>"READ", "Grantee"=>{"URI"=>"http://acs.amazonaws.com/groups/global/AllUsers"}})
        end
      end

      describe "headers" do
        let(:headers) { S3Wrapper.fog_connection.head_object(s3_bucket, path).headers }

        it "has good content_type public" do
          headers['Content-Type'].should eq 'text/html'
        end

        it "has 2 min max-age cache control" do
          headers['Cache-Control'].should eq 's-maxage=300, max-age=120, public'
        end
      end
    end
  end
end