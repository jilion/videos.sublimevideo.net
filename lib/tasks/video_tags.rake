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
    VideoTagStartsUpdaterManagerWorker.perform_async
  end
end
