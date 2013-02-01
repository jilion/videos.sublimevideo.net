class VideoSource < ActiveRecord::Base
  belongs_to :video_tag
  validates :url, :quality, :family, presence: true
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

