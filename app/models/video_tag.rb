class VideoTag < ActiveRecord::Base

  # Replace by once the transition is done:
  # has_many :sources, class_name: "VideoSource", dependent: :destroy
  serialize :current_sources, Array
  serialize :sources, Hash
  has_many :video_sources, dependent: :destroy

  scope :last_30_days_active, -> { where("updated_at >= ?", 30.days.ago.midnight) }
  scope :last_90_days_active, -> { where("updated_at >= ?", 90.days.ago.midnight) }
  scope :by_title, ->(way = 'asc') { order(title: way.to_sym) }
  scope :by_date, ->(way = 'desc') { order(created_at: way.to_sym) }

  validates :site_token, presence: true
  validates :uid, presence: true, uniqueness: { scope: :site_token }
  validates :uid_origin, presence: true, inclusion: %w[attribute source]
  validates :title_origin, inclusion: %w[attribute youtube vimeo], allow_nil: true
  validates :sources_origin, inclusion: %w[youtube vimeo other], allow_nil: true

  def uid=(attr)
    write_attribute :uid, attr.try(:to, 254)
  end

  def title=(attr)
    write_attribute :title, attr.try(:to, 254)
  end

  def duration=(attr)
    duration = attr.to_i > 2147483647 ? 2147483647 : attr.to_i
    write_attribute :duration, duration
  end

  def settings=(settings)
    write_attribute :settings, Hash[settings.map { |k,v| [k.underscore,v] }]
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

