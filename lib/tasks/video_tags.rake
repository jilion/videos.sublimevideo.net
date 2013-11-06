namespace :video_tags do
  desc "Update video_tag starts intelligently, need to be launched every 10 min"
  task update_starts: :environment do
    tokens = Site.tokens(with_addon_plan: 'stats-realtime')
    video_tags = VideoTag
      .where('started_at > ?', 366.days.ago) # avoid to update no more started video_tags
      .where(site_token: tokens)
      .with_valid_uid
    limit = video_tags.count / 150 # 150 is a little more that the number of 10 min during 24h
    video_tags
      .where('starts_updated_at < ? OR starts_updated_at IS NULL', Time.now.beginning_of_day)
      .order(starts_updated_at: :desc)
      .limit(limit * 5)
      .select(:id)
      .each { |video_tag| VideoTagStartsUpdaterWorker.perform_in(rand(600).seconds, video_tag.id) }
  end
end
