require 'spec_helper'

describe VideoTag do
  let(:video_tag) { build(:video_tag) }

  context "Factory" do
    subject { create(:video_tag_with_sources) }

    its(:site_token)      { should be_present }
    its(:uid)             { should be_present }
    its(:uid_origin)      { should eq 'attribute' }
    its(:title)           { should be_present }
    its(:poster_url)      { should eq 'http://media.sublimevideo.net/vpa/ms_800.jpg' }
    its(:size)            { should eq '640x360' }
    its(:duration)        { should eq 10000 }
    its(:settings)        { should eq({ 'on_end' => 'nothing' }) }
    its(:player_stage)    { should eq 'stable' }

    it { should have(2).sources }
    it { should be_valid }
  end

  describe "Associations" do
    it { should have_many(:sources).dependent(:delete_all) }
  end

  describe "Scopes" do
    describe ".last_30_days_active" do
      let!(:old_video_tag) { create(:video_tag, last_30_days_starts: 0) }
      let!(:video_tag) { create(:video_tag, last_30_days_starts: 1) }

      it "returns only recently updated video_tags" do
        VideoTag.last_30_days_active.should eq [video_tag]
      end
    end
    describe ".last_90_days_active" do
      let!(:old_video_tag) { create(:video_tag, last_90_days_starts: 0) }
      let!(:video_tag) { create(:video_tag, last_90_days_starts: 1) }

      it "returns only recently updated video_tags" do
        VideoTag.last_90_days_active.should eq [video_tag]
      end
    end
    describe ".last_365_days_active" do
      let!(:old_video_tag) { create(:video_tag, last_365_days_starts: 0) }
      let!(:video_tag) { create(:video_tag, last_365_days_starts: 1) }

      it "returns only recently updated video_tags" do
        VideoTag.last_365_days_active.should eq [video_tag]
      end
    end

    describe ".by_title" do
      let!(:video_tag_a) { create(:video_tag, title: 'a') }
      let!(:video_tag_b) { create(:video_tag, title: 'b') }

      it "sorts by name ASC by default" do
        VideoTag.by_title.first.should eq video_tag_a
      end

      it "sorts by name order given (DESC)" do
        VideoTag.by_title(:desc).first.should eq video_tag_b
      end
    end

    describe ".by_date" do
      let!(:old_video_tag) { create(:video_tag, created_at: 1.day.ago) }
      let!(:video_tag) { create(:video_tag) }

      it "sorts by created_at DESC by default" do
        VideoTag.by_date.first.should eq video_tag
      end

      it "sorts by name order given (ASC)" do
        VideoTag.by_date(:asc).first.should eq old_video_tag
      end
    end

    describe ".by_starts" do
      let!(:video_tag1) { create(:video_tag, starts: 365.times.map { |i| i + 1 }) }
      let!(:video_tag2) { create(:video_tag, starts: 365.times.map { |i| (i + 1) * 2 }) }

      it "sorts by starts sum" do
        VideoTag.by_starts.map(&:id).should eq [video_tag2, video_tag1].map(&:id)
        VideoTag.by_starts(30, 'asc').map(&:id).should eq [video_tag1, video_tag2].map(&:id)
      end

      it "sets starts_sum for the last 30 days by default" do
        VideoTag.by_starts.first['starts_sum'].should eq 21030
        VideoTag.by_starts.last['starts_sum'].should eq 10515
      end

      it "sets starts_sum for last 1 day" do
        VideoTag.by_starts(1).first['starts_sum'].should eq 730
        VideoTag.by_starts(1).last['starts_sum'].should eq 365
      end
    end

    describe ".duplicates_first_source_url" do
      let(:site_token) { 'site_token' }
      let!(:other_video_tag) { create(:video_tag_with_sources, site_token: site_token, uid_origin: 'source') }
      subject { VideoTag.duplicates_first_source_url(video_tag).first }

      context "with standard video tag" do
        let!(:video_tag) { create(:video_tag_with_sources, site_token: site_token) }
        it { should be_nil }
      end

      context "with video tag with uid from source" do
        let!(:video_tag) { create(:video_tag_with_sources, site_token: site_token, uid_origin: 'source') }
        it { should_not be_readonly }
        it { should be_present }
      end

      context "with video tag with invalid uid from attribute" do
        let!(:video_tag) { create(:video_tag_with_sources, site_token: site_token, uid: 'i.n valid!', uid_origin: 'attribute') }
        it { should_not be_readonly }
        it { should be_present }
      end
    end

    describe ".duplicates_sources_id" do
      let(:site_token) { 'site_token' }
      let!(:other_video_tag) { create(:video_tag, site_token: site_token, uid_origin: 'source', sources_id: 'id', sources_origin: 'vimeo') }
      subject { VideoTag.duplicates_sources_id(video_tag) }

      context "with standard video tag" do
        let!(:video_tag) { create(:video_tag, site_token: site_token) }
        it { should have(0).duplicates }
      end

      context "with video tag with uid from source" do
        let!(:video_tag) { create(:video_tag, site_token: site_token, uid_origin: 'source', sources_id: 'id', sources_origin: 'youtube') }
        it { should have(1).duplicates }
      end
    end

    describe ".search" do
      let(:site_token) { 'site_token' }
      let!(:video_tag) { create(:video_tag, site_token: site_token, title: title) }
      subject { VideoTag.search('sugar') }

      context "with same title of query" do
        let(:title) { 'sugar' }
        it { should have(1).result }
      end

      context "with almost title of query" do
        let(:title) { 'sugor' }
        it { should have(1).result }
      end
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:site_token) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:uid_origin) }
    # it { should validate_uniqueness_of(:uid).scoped_to(:site_token) } # doesn't work with null: false on uid
    it { should ensure_inclusion_of(:uid_origin).in_array(%w[attribute source]) }
    it { should ensure_inclusion_of(:sources_origin).in_array(%w[youtube vimeo other]).allow_nil }
    it { should ensure_inclusion_of(:player_stage).in_array(%w[stable beta alpha]) }
  end

  describe "#valid_uid?" do
    specify { build(:video_tag, uid: '1').should be_valid_uid }
    specify { build(:video_tag, uid: 'a').should be_valid_uid }
    specify { build(:video_tag, uid: 'A').should be_valid_uid }
    specify { build(:video_tag, uid: '_').should be_valid_uid }
    specify { build(:video_tag, uid: '-').should be_valid_uid }
    specify { build(:video_tag, uid: 'a0912-as_dA').should be_valid_uid }

    specify { build(:video_tag, uid: '#').should_not be_valid_uid }
    specify { build(:video_tag, uid: '.').should_not be_valid_uid }
    specify { build(:video_tag, uid: '!').should_not be_valid_uid }
    specify { build(:video_tag, uid: '?').should_not be_valid_uid }
    specify { build(:video_tag, uid: 'a' * 65 ).should_not be_valid_uid }
  end

  describe "#saved_once?" do
    context "with unsaved record" do
      subject { build(:video_tag) }

      it { should_not be_saved_once }
    end

    context "with saved record" do
      subject { create(:video_tag) }

      context "never updated" do
        it { should be_saved_once }
      end

      context "updated once" do
        before { subject.touch }

        it { should_not be_saved_once }
      end
    end
  end

  describe "#uid=" do
    it "truncates long uid" do
      long_uid = ''
      256.times.each { long_uid += 'a' }
      video_tag.update(uid: long_uid)
      video_tag.uid.size.should eq 255
    end
  end

  describe "#title=" do
    it "truncates long title" do
      long_title = ''
      256.times.each { long_title += 'a' }
      video_tag.update(title: long_title)
      video_tag.title.size.should eq 255
    end

    it "sets to nil" do
      video_tag.update(title: nil)
      video_tag.title.should be_nil
    end
  end

  describe "#duration=" do
    it "limits max duration integer" do
      buggy_duration = 6232573214720000
      video_tag.update(duration: buggy_duration)
      video_tag.duration.should be_nil
    end

    it "limits min duration integer" do
      buggy_duration = 6232573214720000
      video_tag.update(duration: buggy_duration)
      video_tag.duration.should be_nil
    end
  end

  describe "#settings=" do
    it "underscorizes keys" do
      camelcase_settings = { 'logoPosition' => 'bottom-right' }
      video_tag.update(settings: camelcase_settings)
      video_tag.settings.should eq({'logo_position' => 'bottom-right'})
    end

    it "accepts nil settings" do
      video_tag.update(settings: nil)
      video_tag.settings.should eq({})
    end
  end

  describe "#sources=" do
    let(:sources) { [
      { url: 'http://example.com/1.mp4' },
      { url: 'http://example.com/2.mp4' },
    ] }

    it "creates sources with position" do
      video_tag.update(sources: sources)
      video_tag.should have(2).sources
      video_tag.sources.first.url.should match /1/
      video_tag.sources.second.url.should match /2/
    end

    it "accepts nil sources" do
      video_tag.update(sources: nil)
      video_tag.should have(0).sources
    end
  end

  describe "#options=" do
    let(:options) { {
      'autoembed' => 'true',
      'foo' => 1,
      'gaAccount' => 'UA-XXXXX-X'
    } }

    it "casts true values" do
      video_tag.update(options: options)
      video_tag.options["autoembed"].should be_true
      video_tag.options["foo"].should be_true
    end

    it "underscorizes keys" do
      video_tag.update(options: options)
      video_tag.options.keys.should include "ga_account"
    end

    it "doesn't change non-true values" do
      video_tag.update(options: options)
      video_tag.options['ga_account'].should eq 'UA-XXXXX-X'
    end

    it "accepts nil options" do
      video_tag.update(options: nil)
      video_tag.should have(0).options
    end
  end
end

# == Schema Information
#
# Table name: video_tags
#
#  created_at           :datetime
#  duration             :integer
#  id                   :integer          not null, primary key
#  last_30_days_starts  :integer
#  last_365_days_starts :integer
#  last_90_days_starts  :integer
#  loaded_at            :datetime
#  options              :hstore
#  player_stage         :string(255)      default("stable")
#  poster_url           :text
#  settings             :hstore
#  site_token           :string(255)      not null
#  size                 :string(255)
#  sources_id           :string(255)
#  sources_origin       :string(255)
#  starts               :integer          default([])
#  starts_updated_at    :datetime
#  title                :string(255)
#  title_origin         :string(255)
#  uid                  :string(255)      not null
#  uid_origin           :string(255)      default("attribute"), not null
#  updated_at           :datetime
#
# Indexes
#
#  index_video_tags_on_loaded_at                            (loaded_at)
#  index_video_tags_on_site_token_and_last_30_days_starts   (site_token,last_30_days_starts)
#  index_video_tags_on_site_token_and_last_365_days_starts  (site_token,last_365_days_starts)
#  index_video_tags_on_site_token_and_last_90_days_starts   (site_token,last_90_days_starts)
#  index_video_tags_on_site_token_and_loaded_at             (site_token,loaded_at)
#  index_video_tags_on_site_token_and_uid                   (site_token,uid) UNIQUE
#  index_video_tags_on_starts_updated_at                    (starts_updated_at)
#

