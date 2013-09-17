class VideoSource < ActiveRecord::Base
  belongs_to :video_tag

  validates :url, presence: true

  after_create :_delay_content_type_check

  private

  def _delay_content_type_check
    if video_tag.valid_uid?
      VideoSourceContentTypeCheckerWorker.perform_in(30.seconds, id)
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

