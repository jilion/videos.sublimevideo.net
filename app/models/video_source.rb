class VideoSource < ActiveRecord::Base
  belongs_to :video_tag

  validates :url, presence: true

  before_create :check_for_issues

  def check_for_issues
    checker = ContentTypeChecker.new(url)

    self.issues = if checker.found?
      if checker.valid_content_type?
        []
      else
        ['content-type-error']
      end
    else
      ['not-found']
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

