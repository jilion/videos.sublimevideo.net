class VideoTag < ActiveRecord::Base
  UID_REGEX = '^[a-z0-9_\-]{1,64}$'

  has_many :sources, -> { order(:position) }, class_name: "VideoSource", dependent: :destroy

  scope :last_30_days_active, -> { where("updated_at >= ?", 30.days.ago.midnight) }
  scope :last_90_days_active, -> { where("updated_at >= ?", 90.days.ago.midnight) }
  scope :by_title, ->(way = 'asc') { order(title: way.to_sym) }
  scope :by_date, ->(way = 'desc') { order(created_at: way.to_sym) }
  scope :duplicates_first_source_url, ->(video_tag) {
    includes(:sources)
    .where(site_token: video_tag.site_token)
    .where("uid_origin = 'source' OR (uid_origin = 'attribute' AND uid !~* '#{UID_REGEX}')")
    .merge(VideoSource.where(
      position: 0,
      url: video_tag.first_source.try(:url)
    ).references(:sources))
  }
  scope :duplicates_sources_id, ->(video_tag) {
    where(
      site_token: video_tag.site_token,
      uid_origin: 'source',
      sources_id: video_tag.sources_id,
      sources_origin: video_tag.sources_origin
    )
  }
  scope :with_uids, ->(uids) { where(uid: uids) }
  scope :with_invalid_uid, -> { where("uid !~* '#{UID_REGEX}'") }

  validates :site_token, presence: true
  validates :uid, presence: true, uniqueness: { scope: :site_token }
  validates :uid_origin, presence: true, inclusion: %w[attribute source]
  validates :title_origin, inclusion: %w[attribute youtube vimeo], allow_nil: true
  validates :sources_origin, inclusion: %w[youtube vimeo other], allow_nil: true

  def self.find_or_initialize(options)
    where(options).first_or_initialize
  end

  def first_source
    sources.first
  end

  def valid_uid?
    uid =~ /#{UID_REGEX}/i
  end

  def saved_once?
    created_at == updated_at
  end

  def uid=(uid)
    write_attribute :uid, uid.try(:to, 254)
  end

  def title=(title)
    write_attribute :title, title.try(:to, 254)
  end

  def duration=(duration)
    duration = duration.to_i.in?(0..2147483647) ? duration.to_i : nil
    write_attribute :duration, duration
  end

  def sources=(sources)
    (sources || []).each_with_index do |attributes, index|
      self.sources.build(attributes.merge(position: index))
    end
  end

  def settings=(settings)
    write_attribute :settings, Hash[(settings || {}).map { |k,v| [k.underscore,v] }]
  end
end

# == Schema Information
#
# Table name: video_tags
#
#  created_at     :datetime
#  duration       :integer
#  id             :integer          not null, primary key
#  options        :hstore
#  poster_url     :text
#  settings       :hstore
#  site_token     :string(255)      not null
#  size           :string(255)
#  sources_id     :string(255)
#  sources_origin :string(255)
#  title          :string(255)
#  title_origin   :string(255)
#  uid            :string(255)      not null
#  uid_origin     :string(255)      default("attribute"), not null
#  updated_at     :datetime
#
# Indexes
#
#  index_video_tags_on_site_token_and_uid         (site_token,uid) UNIQUE
#  index_video_tags_on_site_token_and_updated_at  (site_token,updated_at)
#

