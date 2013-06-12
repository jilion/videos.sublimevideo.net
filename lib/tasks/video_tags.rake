namespace :video_tags do
  desc "Update video_tag starts intelligently, need to be launched every 10 min"
  task update_starts: :environment do
    video_tags = VideoTag
      .where('loaded_at >= ?', 366.days.ago) # avoid to update no more loaded video_tags
      .with_valid_uid
    limit = video_tags.count / 150 # 150 is a little more that the number of 10 min during 24h
    video_tags = video_tags
      .where('starts_updated_at <= ?', 1.days.ago)
      .order(loaded_at: :desc)
      .limit(limit)
    video_tags.select(:id).find_each do |video_tag|
      VideoTagStartsUpdaterWorker.perform_async(video_tag.id)
    end
  end
end
