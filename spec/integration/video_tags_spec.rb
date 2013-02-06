require 'spec_helper'

describe VideoTag do

  describe "update via worker" do
    let(:video_tag) { VideoTag.first }
    let(:site_token) { 'site_token' }
    let(:uid) { 'uid' }

    context "video_tag with public YouTube video", :vcr do
      let(:data) { {
        i: 'DAcjV60RnRw',
        io: 'y'
      }}

      it "creates video_tag properly with title from YouTube" do
        VideoTagUpdaterWorker.perform_async(site_token, uid, data)
        VideoTagUpdaterWorker.drain

        video_tag.site_token.should eq site_token
        video_tag.uid.should eq uid
        video_tag.title.should eq 'Will We Ever Run Out of New Music?'
        video_tag.title_origin.should eq 'youtube'
        video_tag.sources_id.should eq 'DAcjV60RnRw'
        video_tag.sources_origin.should eq 'youtube'
      end
    end

    context "video_tag with public Vimeo video" do
      let(:data) { {
        't' => 'custom video title',
        's' => [
          { 'u' => "http://player.vimeo.com/external/35386044.sd.mp4?s=f10c9e0acaf7cb38e9a5539c6fbcb4ac", 'q' => 'base', 'f' => 'mp4' },
          { 'u' => "http://example.com/video.hd.mp4", 'q' => 'hd', 'f' => 'mp4' }
        ]
      }}

      it "creates video_tag properly with attribute title" do
        VideoTagUpdaterWorker.perform_async(site_token, uid, data)
        VideoTagUpdaterWorker.drain

        video_tag.site_token.should eq site_token
        video_tag.uid.should eq uid
        video_tag.title.should eq 'custom video title'
        video_tag.title_origin.should eq 'attribute'
        video_tag.sources_id.should eq '35386044'
        video_tag.sources_origin.should eq 'vimeo'
        video_tag.sources.should have(2).sources
      end
    end
  end

end
