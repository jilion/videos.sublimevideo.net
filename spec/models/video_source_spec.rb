require 'spec_helper'

describe VideoSource do
  let(:video_source) { build(:video_source) }

  context 'Factory' do
    subject { video_source }

    its(:video_tag)  { should be_present }
    its(:url)        { should be_present }
    its(:family)     { should be_present }
    its(:quality)    { should be_present }
    its(:resolution) { should be_present }

    it { should be_valid }
  end

  describe 'Associations' do
    it { should belong_to :video_tag }
  end

  describe 'Validations' do
    it { should validate_presence_of(:url) }
  end

  describe 'after_create :_delay_content_type_check' do
    it 'delays content type check' do
      VideoSourceContentTypeCheckerWorker.should_receive(:perform_async)

      video_source.save
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

