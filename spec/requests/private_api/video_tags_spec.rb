require 'spec_helper'

describe "VideoTags requests" do
  let(:site_token) { 'site_token' }
  before { set_api_credentials }

  describe "index" do
    before {
      3.times { create(:video_tag, site_token: site_token) }
    }

    it "supports per scope" do
      get "private_api/sites/#{site_token}/video_tags.json", { per: 2 }, @env
      MultiJson.load(response.body).should have(2).video_tag
    end

    it "supports select scope" do
      get "private_api/sites/#{site_token}/video_tags.json", { select: %w[uid title] }, @env
      video_tag = MultiJson.load(response.body).first
      video_tag.should have_key("uid")
      video_tag.should have_key("title")
      video_tag.should_not have_key("uid_origin")
    end

    it "supports with_uids scope" do
      uids = VideoTag.pluck(:uid)[0, 2]
      get "private_api/sites/#{site_token}/video_tags.json", { with_uids: uids }, @env
      MultiJson.load(response.body).should have(2).video_tag
    end
  end

  describe "show" do
    let(:video_tag) { create(:video_tag, site_token: site_token) }

    it "finds video_tag per uid" do
      get "private_api/sites/#{site_token}/video_tags/#{video_tag.uid}.json", {}, @env
      MultiJson.load(response.body).should_not have_key("video_tag")
    end
  end

  describe "count" do
    before {
      3.times { |i| create(:video_tag, site_token: site_token, updated_at: (16 * i).days.ago) }
    }

    it "supports last_30_days_active scope" do
      get "private_api/sites/#{site_token}/video_tags/count.json", { last_30_days_active: true }, @env
      MultiJson.load(response.body).should eq({"count" => 2})
    end
  end

  describe "site_tokens" do
    before {
      3.times { create(:video_tag, site_token: site_token) }
    }

    it "supports with_invalid_uid scope" do
      VideoTag.first.update(uid: ' a ')
      get "private_api/video_tags/site_tokens.json", { with_invalid_uid: true }, @env
      MultiJson.load(response.body).should eq({ "site_tokens" => [VideoTag.first.site_token] })
    end
  end


end
