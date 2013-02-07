require 'spec_helper'

describe VideoTagMigrator do

  it "updates sources & title fields without touching updated_at" do
    video_tag = VideoTag.create(
      site_token: 'site_token',
      uid: 'uid',
      title: 'filename title',
      poster_url: nil,
      size: nil,
      duration: 0,
      current_sources: ['53738092', '1231asd1']
    )
    video_tag.update_columns(
      uid_origin: 'source',
      title_origin: 'source',
    )
    video_tag.send('write_attribute', :sources, {
      "1231asd1" => { url: "http://example.com/video.hd.mp4", quality: "hd", family: "mp4" },
      "53738092" => { url: "http://example.com/video.mp4", quality: "base", family: "mp4" },
      "other"    => { url: "http://whatever.com/video.mp4", quality: "base", family: "mp4" }
    })
    old_updated_at = video_tag.updated_at

    VideoTagMigrator.new(video_tag).migrate

    video_tag = VideoTag.first
    video_tag.uid.should eq 'uid'
    video_tag.uid_origin.should eq 'source'
    video_tag.site_token.should eq 'site_token'
    video_tag.title.should be_nil
    video_tag.title_origin.should be_nil
    video_tag.should have(2).sources
    video_tag.sources.first.url.should eq "http://example.com/video.mp4"
    video_tag.sources.second.url.should eq "http://example.com/video.hd.mp4"
    video_tag.sources_id.should be_nil
    video_tag.sources_origin.should eq 'other'
    video_tag.settings.should eq({})
    video_tag.options.should be_nil
    video_tag.updated_at.should eq old_updated_at
    video_tag.should be_valid
  end

end
