require 'spec_helper'

describe VideoSource do
  let(:video_source) { build(:video_source) }

  context "Factory" do
    subject { video_source }

    its(:video_tag)       { should be_present }
    its(:url)             { should be_present }
    its(:family)          { should be_present }
    its(:quality)         { should be_present }
    its(:resolution)      { should be_present }

    it { should be_valid }
  end

  describe "Associations" do
    it { should belong_to :video_tag }
  end

  describe "Validations" do
    it { should validate_presence_of(:url) }
  end
end

# == Schema Information
#
# Table name: video_sources
#
#  created_at   :datetime
#  family       :string(255)      not null
#  id           :integer          not null, primary key
#  quality      :string(255)      not null
#  resolution   :string(255)
#  updated_at   :datetime
#  url          :string(255)      not null
#  video_tag_id :integer          not null
#
# Indexes
#
#  index_video_sources_on_video_tag_id  (video_tag_id)
#

