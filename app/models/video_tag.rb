class VideoTag < ActiveRecord::Base
  UID_REGEX = '^[a-z0-9_\-]{1,64}$'

  has_many :sources, -> { order(:position) }, class_name: 'VideoSource', dependent: :delete_all

  scope :last_30_days_active, -> { where('last_30_days_starts > 0') }
  scope :last_90_days_active, -> { where('last_90_days_starts > 0') }
  scope :last_365_days_active, -> { where('last_365_days_starts > 0') }
  scope :inactive, -> { where(last_365_days_starts: 0) }
  scope :by_title, ->(way = 'asc') { order(title: way.to_sym) }
  scope :by_date, ->(way = 'desc') { order(created_at: way.to_sym) }
  scope :by_last_30_days_starts, ->(way = 'desc') { order(last_30_days_starts: way.to_sym) }
  scope :by_last_90_days_starts, ->(way = 'desc') { order(last_90_days_starts: way.to_sym) }
  scope :by_last_365_days_starts, ->(way = 'desc') { order(last_365_days_starts: way.to_sym) }
  scope :by_starts, ->(last_days = 30, way = 'desc') {
    select("*, (SELECT SUM(t) FROM UNNEST(starts[#{366 - last_days}:365]) t) as starts_sum").order("starts_sum #{way}") }

  scope :with_uids, ->(uids) { where(uid: uids) }
  scope :with_invalid_uid, -> { where("uid !~* '#{UID_REGEX}'") }
  scope :with_valid_uid, -> { where(uid_origin: 'attribute').where("uid ~* '#{UID_REGEX}'") }
  scope :search, ->(query) { basic_search(title: query) }

  validates :site_token, presence: true, format: /[a-z0-9]{8}/
  validates :uid, presence: true, uniqueness: { scope: :site_token }
  validates :uid_origin, presence: true, inclusion: %w[attribute source]
  validates :title_origin, inclusion: %w[attribute youtube vimeo], allow_nil: true
  validates :sources_origin, inclusion: %w[youtube vimeo other], allow_nil: true
  validates :player_stage, inclusion: %w[stable beta alpha]

  after_create :_delay_increment_site_counter

  def self.find_or_initialize(options)
    where(options).first_or_initialize
  end

  def as_json(options = nil)
    super((options || {}).merge(include: :sources, methods: :hosted_by))
  end

  def first_source
    sources.first
  end

  def valid_uid?
    uid =~ /#{UID_REGEX}/i
  end

  def saved_once?
    persisted? && created_at == updated_at
  end

  def hosted_by
    SourceHostDetector.new(self).hosted_by
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
    self.sources.delete_all
    (sources || []).each_with_index do |attributes, index|
      self.sources.build(attributes.merge(position: index))
    end
  end

  def settings=(settings)
    write_attribute :settings, Hash[(settings || {}).map { |k, v| [k.underscore, v] }]
  end

  def options=(options)
    write_attribute :options, Hash[(options || {}).map { |k, v|
      [k.underscore, v.in?([1, '1', 'true', true]) || v]
    }]
  end

  private

  def _delay_increment_site_counter
    SiteCounterIncrementerWorker.perform_async(site_token, :last_30_days_video_tags)
  end

end

# == Schema Information
#
# Table name: video_tags
#
#  created_at           :datetime
#  duration             :integer
#  id                   :integer          not null, primary key
#  last_30_days_starts  :integer
#  last_365_days_starts :integer
#  last_90_days_starts  :integer
#  loaded_at            :datetime
#  options              :hstore
#  player_stage         :string(255)      default("stable")
#  poster_url           :text
#  settings             :hstore
#  site_token           :string(255)      not null
#  size                 :string(255)
#  sources_id           :string(255)
#  sources_origin       :string(255)
#  starts               :integer          default([])
#  starts_updated_at    :datetime
#  title                :string(255)
#  title_origin         :string(255)
#  uid                  :string(255)      not null
#  uid_origin           :string(255)      default("attribute"), not null
#  updated_at           :datetime
#
# Indexes
#
#  index_video_tags_on_loaded_at                            (loaded_at)
#  index_video_tags_on_site_token_and_last_30_days_starts   (site_token,last_30_days_starts)
#  index_video_tags_on_site_token_and_last_365_days_starts  (site_token,last_365_days_starts)
#  index_video_tags_on_site_token_and_last_90_days_starts   (site_token,last_90_days_starts)
#  index_video_tags_on_site_token_and_loaded_at             (site_token,loaded_at)
#  index_video_tags_on_site_token_and_uid                   (site_token,uid) UNIQUE
#  index_video_tags_on_starts_updated_at                    (starts_updated_at)
#

