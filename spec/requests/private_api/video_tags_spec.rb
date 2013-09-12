require 'spec_helper'

describe "VideoTags requests" do
  let(:site_token) { 'site_token' }
  before { set_api_credentials }

  describe "index" do
    let(:url) { "private_api/sites/#{site_token}/video_tags.json" }
    let(:time) { 1.minute.ago }
    let!(:video_tag1) { create(:video_tag, site_token: site_token, created_at: time, title: 'foo') }
    let!(:video_tag2) { create(:video_tag, site_token: site_token, created_at: time, title: 'a') }
    let!(:video_tag3) { create(:video_tag, site_token: site_token) }

    it_behaves_like 'valid caching headers', cache_validation: false, cache_control: 'public'

    it "supports per scope" do
      get url, { per: 2 }, @env
      MultiJson.load(response.body).should have(2).video_tag
    end

    it "supports search scope" do
      get url, { search: 'foo' }, @env
      MultiJson.load(response.body).should have(1).video_tag
    end

    it "always sorts by_title in last position" do
      get url, { by_date: 'desc' }, @env
      MultiJson.load(response.body).map { |v| v['id'] }.should eq(
        [video_tag3.id, video_tag2.id, video_tag1.id])
    end

    it "supports select scope" do
      get url, { select: %w[uid title] }, @env
      video_tag = MultiJson.load(response.body).first
      video_tag.should have_key("uid")
      video_tag.should have_key("title")
      video_tag.should_not have_key("uid_origin")
    end

    it "includes sources" do
      get url, {}, @env
      video_tag = MultiJson.load(response.body).first
      video_tag.should have_key("sources")
    end

    it "supports with_uids scope" do
      uids = VideoTag.pluck(:uid)[0, 2]
      get url, { with_uids: uids }, @env
      MultiJson.load(response.body).should have(2).video_tag
    end
  end

  describe "show" do
    let(:video_tag) { create(:video_tag, site_token: site_token, sources: [build(:video_source).attributes]) }
    let(:url) { "private_api/sites/#{site_token}/video_tags/#{video_tag.uid}.json" }

    it_behaves_like 'valid caching headers', cache_control: 'public' do
      let(:record) { video_tag }
    end

    it 'finds video_tag per uid' do
      get url, {}, @env
      MultiJson.load(response.body).should_not have_key('video_tag')
    end

    it 'includes sources' do
      get url, {}, @env
      MultiJson.load(response.body).should have_key('sources')
    end

    it 'sources includes issues' do
      get url, {}, @env
      MultiJson.load(response.body)['sources'][0].should have_key('issues')
    end
  end

  describe "count" do
    let(:url) { "private_api/sites/#{site_token}/video_tags/count.json" }
    before {
      create(:video_tag, site_token: site_token, last_30_days_starts: 0)
      create(:video_tag, site_token: site_token, last_30_days_starts: 1)
    }

    it_behaves_like 'valid caching headers', cache_validation: false

    it "supports last_30_days_active scope" do
      get url, { last_30_days_active: true }, @env
      MultiJson.load(response.body).should eq({"count" => 1})
    end
  end
end
