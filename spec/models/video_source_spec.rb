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

  describe 'before_create :check_for_issues' do
    let(:content_type_checker) { double }

    before { ContentTypeChecker.should_receive(:new).with(video_source.url) { content_type_checker } }

    context 'source has no issues' do
      it 'leaves the issues array empty' do
        content_type_checker.should_receive(:found?) { true }
        content_type_checker.should_receive(:valid_content_type?) { true }
        video_source.save

        expect(video_source.issues).to be_empty
      end
    end

    context 'source cannot be found' do
      it 'leaves the issues array empty' do
        content_type_checker.should_receive(:found?) { false }
        video_source.save

        expect(video_source.issues).to eq ['not-found']
      end
    end

    context 'source has a wrong mime type' do
      it 'leaves the issues array empty' do
        content_type_checker.should_receive(:found?) { true }
        content_type_checker.should_receive(:valid_content_type?) { false }
        video_source.save

        expect(video_source.issues).to eq ['content-type-error']
      end
    end
  end
end

# == Schema Information
#
# Table name: video_sources
#
#  created_at   :datetime
#  family       :string(255)
#  id           :integer          not null, primary key
#  issues       :string(255)      default([])
#  position     :integer
#  quality      :string(255)
#  resolution   :string(255)
#  updated_at   :datetime
#  url          :text             not null
#  video_tag_id :integer          not null
#
# Indexes
#
#  index_video_sources_on_video_tag_id  (video_tag_id)
#

