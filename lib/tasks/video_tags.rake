namespace :video_tags do

  # Scheduled (Heroku) every day
  desc "Destroy all old video_tags not started for more than a year."
  task destroy_all_old: :environment do
    limit_date = (1.year + 1.day).ago
    video_tags = VideoTag.where("created_at < ? AND (started_at < ? OR started_at IS NULL)", limit_date, limit_date)
    video_tags.destroy_all
  end

  # Scheduled (Heroku) every 10min
  desc "Update video_tag starts intelligently, need to be launched every 10 min."
  task update_starts: :environment do
    tokens = Site.tokens(with_addon_plan: 'stats-realtime')
    video_tags = VideoTag.where(site_token: tokens)
    # 150 is a little more that the number of 10 min during 24h
    limit = Rails.cache.fetch('update_starts_limit', expires_in: 1.day) { VideoTag.count / 150 }
    video_tags
      .where('starts_updated_at < ? OR starts_updated_at IS NULL', Time.now.beginning_of_day)
      .order(started_at: :desc) # update last started_at first
      .limit(limit * 3)
      .select(:id)
      .each { |video_tag| VideoTagStartsUpdaterWorker.perform_in(rand(600).seconds, video_tag.id) }
  end
end
