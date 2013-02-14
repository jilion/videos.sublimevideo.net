class VideoTag < ActiveRecord::Base

  # Replace by once the migration is done:
  # has_many :sources, -> { order(:position) }, class_name: "VideoSource", dependent: :destroy
  serialize :current_sources, Array
  serialize :sources, Hash
  has_many :video_sources, -> { order(:position) }, dependent: :destroy
  def sources
    video_sources
  end

  scope :last_30_days_active, -> { where("updated_at >= ?", 30.days.ago.midnight) }
  scope :last_90_days_active, -> { where("updated_at >= ?", 90.days.ago.midnight) }
  scope :by_title, ->(way = 'asc') { order(title: way.to_sym) }
  scope :by_date, ->(way = 'desc') { order(created_at: way.to_sym) }
  scope :duplicates_first_source_url, ->(video_tag) {
    joins(:video_sources).where(
      site_token: video_tag.site_token,
      uid_origin: 'source',
      video_sources: {
        position: 0, url: video_tag.first_source.url
      }
    )
  }
  scope :duplicates_sources_id, ->(video_tag) {
    where(
      site_token: video_tag.site_token,
      uid_origin: 'source',
      sources_id: video_tag.sources_id,
      sources_origin: video_tag.sources_origin
    )
  }

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
    uid =~ /^[a-z0-9_\-]{1,64}$/i
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
    write_attribute :duration, [duration.to_i, 2147483647].min
  end

  def sources=(sources)
    (sources || []).each_with_index do |attributes, index|
      self.video_sources.build(attributes.merge(position: index))
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

