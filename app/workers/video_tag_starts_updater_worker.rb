require 'sidekiq'

class VideoTagStartsUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(video_tag_id)
    video_tag = VideoTag.find(video_tag_id)

    # Reset invalid starts logic
    if video_tag.starts_updated_at? && video_tag.starts_updated_at < Time.utc(2013,11,07,16)
      video_tag.starts_updated_at = nil
    end

    VideoTagStartsUpdater.new(video_tag).update
  end
end
