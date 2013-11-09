require 'sidekiq'

class VideoTagStartsUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(video_tag_id)
    video_tag = VideoTag.find(video_tag_id)
    VideoTagStartsUpdater.new(video_tag).update
  end
end
