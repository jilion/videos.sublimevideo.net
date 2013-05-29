require 'spec_helper'

describe VideoTag do

  describe "update via worker" do
    let(:video_tag) { VideoTag.first }
    let(:site_token) { 'site_token' }
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

        video_tag.site_token.should eq site_token
        video_tag.uid.should eq uid
        video_tag.title.should eq 'Will We Ever Run Out of New Music?'
        video_tag.title_origin.should eq 'youtube'
        video_tag.sources_id.should eq 'DAcjV60RnRw'
        video_tag.sources_origin.should eq 'youtube'
        video_tag.player_stage.should eq 'beta'
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

        video_tag.site_token.should eq site_token
        video_tag.uid.should eq uid
        video_tag.title.should eq 'custom video title'
        video_tag.title_origin.should eq 'attribute'
        video_tag.sources_id.should eq '35386044'
        video_tag.sources_origin.should eq 'vimeo'
        video_tag.created_at.should be <= 1.year.ago
        video_tag.updated_at.should be <= 1.month.ago
        video_tag.should have(2).sources
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
      let(:path) { 'e/site_token/uid.html' }

      it "uploads autoembed file" do
        VideoTagUpdaterWorker.perform_async(site_token, uid, data)
        VideoTagUpdaterWorker.drain
        AutoEmbedFileUploaderWorker.drain

        body = S3Wrapper.get_object(path).body
        body.should include "<!DOCTYPE html>"
        body.should include "/js/site_token.js"
        body.should include "_gaq.push(['_setAccount', 'UA-12345-6']);"
      end
    end
  end

  describe "plays", :focus do
    let!(:video_tag1) { create(:video_tag, plays: 365.times.map { |i| i }) }
    let!(:video_tag2) { create(:video_tag, plays: 365.times.map { |i| i * 2 }) }

    it "description" do
      a = VideoTag.select('(SELECT SUM(t) FROM UNNEST(plays[0:30]) t) as plays_sum').order('plays_sum')
      p a.to_sql
      p a.first['plays_sum']
    end
  end

end
