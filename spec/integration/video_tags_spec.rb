require 'spec_helper'

describe VideoTag do

  describe "update via worker" do
    let(:video_tag) { VideoTag.first }
    let(:site_token) { 'abcd1234' }
    let(:uid) { 'uid' }

    before { VideoTagUpdaterWorker.jobs.clear }

    context "video_tag with public YouTube video" do
      let(:data) { {
        i: 'DAcjV60RnRw',
        io: 'y',
        st: 'b'
      }}

      it "creates video_tag properly with title from YouTube", :vcr do
        VideoTagUpdaterWorker.perform_async(site_token, uid, data)
        VideoTagUpdaterWorker.drain

        expect(video_tag.site_token).to eq site_token
        expect(video_tag.uid).to eq uid
        expect(video_tag.title).to eq 'Will We Ever Run Out of New Music?'
        expect(video_tag.title_origin).to eq 'youtube'
        expect(video_tag.sources_id).to eq 'DAcjV60RnRw'
        expect(video_tag.sources_origin).to eq 'youtube'
        expect(video_tag.player_stage).to eq 'beta'
      end
    end

    context "video_tag with public Vimeo video" do
      let(:data) { {
        't' => 'custom video title',
        's' => [
          { 'u' => "http://player.vimeo.com/external/35386044.sd.mp4?s=f10c9e0acaf7cb38e9a5539c6fbcb4ac", 'q' => 'base', 'f' => 'mp4' },
          { 'u' => "http://example.com/video.hd.mp4", 'q' => 'hd', 'f' => 'mp4' }
        ],
        'created_at' => 1.year.ago,
        'updated_at' => 1.month.ago
      }}

      it "creates video_tag properly with attribute title" do
        VideoTagUpdaterWorker.perform_async(site_token, uid, data)
        VideoTagUpdaterWorker.drain

        expect(video_tag.site_token).to eq site_token
        expect(video_tag.uid).to eq uid
        expect(video_tag.title).to eq 'custom video title'
        expect(video_tag.title_origin).to eq 'attribute'
        expect(video_tag.sources_id).to eq '35386044'
        expect(video_tag.sources_origin).to eq 'vimeo'
        expect(video_tag.created_at).to be <= 1.year.ago
        expect(video_tag.updated_at).to be <= 1.month.ago
        expect(video_tag).to have(2).sources
      end
    end

    context "video_tag with autoembed & ga_account enabled", :fog_mock do
      let(:data) { {
        't' => 'video title',
        's' => [
          { 'u' => "http://example.com/video.mp4", 'q' => 'base', 'f' => 'mp4' },
          { 'u' => "http://example.com/video.hd.mp4", 'q' => 'hd', 'f' => 'mp4' }
        ],
        'o' => { 'autoembed' => 'true', 'gaAccount' => 'UA-12345-6' }
      }}
      let(:path) { "e/#{site_token}/uid.html" }

      it "uploads autoembed file" do
        VideoTagUpdaterWorker.perform_async(site_token, uid, data)
        VideoTagUpdaterWorker.drain
        AutoEmbedFileUploaderWorker.drain

        body = S3Wrapper.get_object(path).body
        expect(body).to include "<!DOCTYPE html>"
        expect(body).to include "/js/#{site_token}.js"
        expect(body).to include "_gaq.push(['_setAccount', 'UA-12345-6']);"
      end
    end
  end
end
