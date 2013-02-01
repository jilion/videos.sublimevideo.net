require "spec_helper"

describe VideoTag do
  let(:video_tag) { build(:video_tag) }

  context "Factory" do
    subject { create(:video_tag_with_sources) }

    its(:site_token)      { should be_present }
    its(:uid)             { should be_present }
    its(:uid_origin)      { should eq 'attribute' }
    its(:title)           { should be_present }
    its(:title_origin)    { should eq 'attribute' }
    its(:poster_url)      { should eq 'http://media.sublimevideo.net/vpa/ms_800.jpg' }
    its(:size)            { should eq '640x360' }
    its(:duration)        { should eq 10000 }
    its(:video_sources)   { should have(2).sources }
    its(:settings)        { should eq({ 'on_end' => 'nothing' }) }

    it { should be_valid }
  end

  describe "Associations" do
    it { should have_many(:video_sources).dependent(:destroy) }
    # it { should have_many(:sources).dependent(:destroy) }
  end

  describe "Scopes" do
    describe ".last_30_days_active" do
      let!(:old_video_tag) { create(:video_tag, updated_at: 31.day.ago) }
      let!(:video_tag) { create(:video_tag) }

      it "returns only recently updated video_tags" do
        VideoTag.last_30_days_active.should eq [video_tag]
      end
    end
    describe ".last_90_days_active" do
      let!(:old_video_tag) { create(:video_tag, updated_at: 91.day.ago) }
      let!(:video_tag) { create(:video_tag) }

      it "returns only recently updated video_tags" do
        VideoTag.last_90_days_active.should eq [video_tag]
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
  end

  describe "Validations" do
    it { should validate_presence_of(:site_token) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:uid_origin) }
    # it { should validate_uniqueness_of(:uid).scoped_to(:site_token) } # doesn't work with null: false on uid
    it { should ensure_inclusion_of(:title_origin).in_array(%w[attribute youtube vimeo]).allow_nil }
    it { should ensure_inclusion_of(:uid_origin).in_array(%w[attribute source]) }
    it { should ensure_inclusion_of(:sources_origin).in_array(%w[youtube vimeo other]).allow_nil }
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
      video_tag.duration.should eq 2147483647
    end
  end

  describe "#settings=" do
    it "underscorizes settings" do
      camelcase_settings = { 'logoPosition' => 'bottom-right' }
      video_tag.update(settings: camelcase_settings)
      video_tag.settings.should eq({'logo_position' => 'bottom-right'})
    end
  end
end

# == Schema Information
#
# Table name: video_tags
#
#  created_at      :datetime
#  current_sources :text
#  duration        :integer
#  id              :integer          not null, primary key
#  options         :hstore
#  poster_url      :text
#  settings        :hstore
#  site_token      :string(255)      not null
#  size            :string(255)
#  sources         :text
#  sources_id      :string(255)
#  sources_origin  :string(255)
#  title           :string(255)
#  title_origin    :string(255)
#  uid             :string(255)      not null
#  uid_origin      :string(255)      default("attribute"), not null
#  updated_at      :datetime
#
# Indexes
#
#  index_video_tags_on_site_token_and_uid         (site_token,uid) UNIQUE
#  index_video_tags_on_site_token_and_updated_at  (site_token,updated_at)
#

