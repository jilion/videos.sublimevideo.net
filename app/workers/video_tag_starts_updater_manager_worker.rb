require 'sidekiq'

class VideoTagStartsUpdaterManagerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform
    _video_tags
      .where('starts_updated_at < ? OR starts_updated_at IS NULL', Time.now.beginning_of_day)
      .order(started_at: :desc) # update last started_at first
      .limit(_limit)
      .select(:id)
      .each { |video_tag| VideoTagStartsUpdaterWorker.perform_in(rand(600).seconds, video_tag.id) }
  end

  private

  def _video_tags
    VideoTag.where(site_token: _site_tokens_with_realtime_stats)
  end

  def _site_tokens_with_realtime_stats
    Site.tokens(with_addon_plan: 'stats-realtime')
  end

  # A little more that the number of 10 min during 24h
  def _limit
    Rails.cache.fetch('update_starts_limit', expires_in: 1.day) do
      _video_tags.count / 150
    end
  end

end
