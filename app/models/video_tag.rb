class VideoTag < ActiveRecord::Base
  has_many :sources, class_name: "VideoSource", dependent: :destroy

  scope :last_30_days_active, -> { where("updated_at >= ?", 30.days.ago.midnight) }
  scope :last_90_days_active, -> { where("updated_at >= ?", 90.days.ago.midnight) }
  scope :by_name, ->(way = 'asc') { order(name: way.to_sym) }
  scope :by_date, ->(way = 'desc') { order(created_at: way.to_sym) }

  validates :site_token, presence: true
  validates :uid, presence: true, uniqueness: { scope: :site_token }
  validates :uid_origin, presence: true, inclusion: %w[attribute source]
  validates :name_origin, inclusion: %w[attribute youtube vimeo], allow_nil: true
  validates :sources_origin, inclusion: %w[youtube vimeo other], allow_nil: true

  def uid=(attribute)
    write_attribute :uid, attribute.try(:to, 254)
  end

  def name=(attribute)
    write_attribute :name, attribute.try(:to, 254)
  end

  def duration=(attribute)
    duration = attribute.to_i > 2147483647 ? 2147483647 : attribute.to_i
    write_attribute :duration, duration
  end
end

# == Schema Information
#
# Table name: video_tags
#
#  created_at     :datetime
#  duration       :integer
#  id             :integer          not null, primary key
#  name           :string(255)
#  name_origin    :string(255)
#  poster_url     :text
#  settings       :hstore
#  site_token     :string(255)      not null
#  size           :string(255)
#  sources        :text
#  sources_id     :string(255)
#  sources_origin :string(255)
#  uid            :string(255)      not null
#  uid_origin     :string(255)      default("attribute"), not null
#  updated_at     :datetime
#
# Indexes
#
#  index_video_tags_on_site_token_and_uid         (site_token,uid) UNIQUE
#  index_video_tags_on_site_token_and_updated_at  (site_token,updated_at)
#

