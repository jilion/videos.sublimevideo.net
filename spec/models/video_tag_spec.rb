require 'spec_helper'

describe VideoTag do
  let(:video_tag) { build(:video_tag) }

  context "Factory" do
    subject { create(:video_tag_with_sources) }

    its(:site_token)   { should be_present }
    its(:uid)          { should be_present }
    its(:uid_origin)   { should eq 'attribute' }
    its(:title)        { should be_present }
    its(:poster_url)   { should eq 'http://media.sublimevideo.net/vpa/ms_800.jpg' }
    its(:size)         { should eq '640x360' }
    its(:duration)     { should eq 10000 }
    its(:settings)     { should eq({ 'on_end' => 'nothing' }) }
    its(:player_stage) { should eq 'stable' }

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
        expect(VideoTag.last_30_days_active).to eq [video_tag]
      end
    end
    describe ".last_90_days_active" do
      let!(:old_video_tag) { create(:video_tag, last_90_days_starts: 0) }
      let!(:video_tag) { create(:video_tag, last_90_days_starts: 1) }

      it "returns only recently updated video_tags" do
        expect(VideoTag.last_90_days_active).to eq [video_tag]
      end
    end
    describe ".last_365_days_active" do
      let!(:old_video_tag) { create(:video_tag, last_365_days_starts: 0) }
      let!(:video_tag) { create(:video_tag, last_365_days_starts: 1) }

      it "returns only recently updated video_tags" do
        expect(VideoTag.last_365_days_active).to eq [video_tag]
      end
    end
    describe ".inactive" do
      let!(:old_video_tag) { create(:video_tag, last_365_days_starts: 0) }
      let!(:video_tag) { create(:video_tag, last_365_days_starts: 1) }

      it "returns only recently updated video_tags" do
        expect(VideoTag.inactive).to eq [old_video_tag]
      end
    end

    describe ".by_title" do
      let!(:video_tag_a) { create(:video_tag, title: 'a') }
      let!(:video_tag_b) { create(:video_tag, title: 'b') }

      it "sorts by name ASC by default" do
        expect(VideoTag.by_title.first).to eq video_tag_a
      end

      it "sorts by name order given (DESC)" do
        expect(VideoTag.by_title(:desc).first).to eq video_tag_b
      end
    end

    describe ".by_date" do
      let!(:old_video_tag) { create(:video_tag, created_at: 1.day.ago) }
      let!(:video_tag) { create(:video_tag) }

      it "sorts by created_at DESC by default" do
        expect(VideoTag.by_date.first).to eq video_tag
      end

      it "sorts by name order given (ASC)" do
        expect(VideoTag.by_date(:asc).first).to eq old_video_tag
      end
    end

    describe ".by_starts" do
      let!(:video_tag1) { create(:video_tag, starts: 365.times.map { |i| i + 1 }) }
      let!(:video_tag2) { create(:video_tag, starts: 365.times.map { |i| (i + 1) * 2 }) }

      it "sorts by starts sum" do
        expect(VideoTag.by_starts.map(&:id)).to eq [video_tag2, video_tag1].map(&:id)
        expect(VideoTag.by_starts(30, 'asc').map(&:id)).to eq [video_tag1, video_tag2].map(&:id)
      end

      it "sets starts_sum for the last 30 days by default" do
        expect(VideoTag.by_starts.first['starts_sum']).to eq 21030
        expect(VideoTag.by_starts.last['starts_sum']).to eq 10515
      end

      it "sets starts_sum for last 1 day" do
        expect(VideoTag.by_starts(1).first['starts_sum']).to eq 730
        expect(VideoTag.by_starts(1).last['starts_sum']).to eq 365
      end
    end

    describe ".search" do
      let(:site_token) { 'abcd1234' }
      let!(:video_tag) { create(:video_tag, site_token: site_token, title: title) }
      subject { VideoTag.search('sugar') }

      context "with same title of query" do
        let(:title) { 'sugar' }
        it { should have(1).result }
      end

      context "with almost title of query" do
        let(:title) { 'sugor' }
        it { should have(0).result }
      end
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:site_token) }
    it { should allow_value("1234abcd").for(:site_token) }
    it { should_not allow_value("123").for(:site_token) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:uid_origin) }
    # it { should validate_uniqueness_of(:uid).scoped_to(:site_token) } # doesn't work with null: false on uid
    it { should ensure_inclusion_of(:uid_origin).in_array(%w[attribute source]) }
    it { should ensure_inclusion_of(:sources_origin).in_array(%w[youtube vimeo other]).allow_nil }
    it { should ensure_inclusion_of(:player_stage).in_array(%w[stable beta alpha]) }
  end

  describe 'after_create :_delay_increment_site_counter' do
    it 'delays site counter incrementation' do
      expect(SiteCounterIncrementerWorker).to receive(:perform_async).with(video_tag.site_token, :last_30_days_video_tags)
      video_tag.save
    end
  end

  describe "#valid_uid?" do
    specify { expect(build(:video_tag, uid: '1')).to be_valid_uid }
    specify { expect(build(:video_tag, uid: 'a')).to be_valid_uid }
    specify { expect(build(:video_tag, uid: 'A')).to be_valid_uid }
    specify { expect(build(:video_tag, uid: '_')).to be_valid_uid }
    specify { expect(build(:video_tag, uid: '-')).to be_valid_uid }
    specify { expect(build(:video_tag, uid: 'a0912-as_dA')).to be_valid_uid }

    specify { expect(build(:video_tag, uid: '#')).not_to be_valid_uid }
    specify { expect(build(:video_tag, uid: '.')).not_to be_valid_uid }
    specify { expect(build(:video_tag, uid: '!')).not_to be_valid_uid }
    specify { expect(build(:video_tag, uid: '?')).not_to be_valid_uid }
    specify { expect(build(:video_tag, uid: 'a' * 65 )).not_to be_valid_uid }
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

  describe "#hosted_by" do
    let(:detector) { double(SourceHostDetector) }

    it "delegates to SourceHosterDetector" do
      expect(SourceHostDetector).to receive(:new).with(video_tag) { detector }
      expect(detector).to receive(:hosted_by) { 'foo' }
      expect(video_tag.hosted_by).to eq 'foo'
    end
  end

  describe "#uid=" do
    it "truncates long uid" do
      long_uid = ''
      256.times.each { long_uid += 'a' }
      video_tag.update(uid: long_uid)
      expect(video_tag.uid.size).to eq 255
    end
  end

  describe "#title=" do
    it "truncates long title" do
      long_title = ''
      256.times.each { long_title += 'a' }
      video_tag.update(title: long_title)
      expect(video_tag.title.size).to eq 255
    end

    it "sets to nil" do
      video_tag.update(title: nil)
      expect(video_tag.title).to be_nil
    end
  end

  describe "#settings=" do
    it "underscorizes keys" do
      camelcase_settings = { 'logoPosition' => 'bottom-right' }
      video_tag.update(settings: camelcase_settings)
      expect(video_tag.settings).to eq({'logo_position' => 'bottom-right'})
    end

    it "accepts nil settings" do
      video_tag.update(settings: nil)
      expect(video_tag.settings).to eq({})
    end
  end

  describe "#sources=" do
    let(:sources) { [
      { url: 'http://example.com/1.mp4' },
      { url: 'http://example.com/2.mp4' },
    ] }

    it "creates sources with position" do
      video_tag.update(sources: sources)
      expect(video_tag).to have(2).sources
      expect(video_tag.sources.first.url).to match /1/
      expect(video_tag.sources.second.url).to match /2/
    end

    it "accepts nil sources" do
      video_tag.update(sources: nil)
      expect(video_tag).to have(0).sources
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
      expect(video_tag.options["autoembed"]).to be_true
      expect(video_tag.options["foo"]).to be_true
    end

    it "underscorizes keys" do
      video_tag.update(options: options)
      expect(video_tag.options.keys).to include "ga_account"
    end

    it "doesn't change non-true values" do
      video_tag.update(options: options)
      expect(video_tag.options['ga_account']).to eq 'UA-XXXXX-X'
    end

    it "accepts nil options" do
      video_tag.update(options: nil)
      expect(video_tag).to have(0).options
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

