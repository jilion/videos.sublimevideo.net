require 'sidekiq'

require 'video_tag_duplicate_remover'

class VideoTagDuplicateRemoverWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos_low'

  def self.perform_async_if_needed(video_tag)
    if video_tag.saved_once? && video_tag.valid_uid?
      perform_async(video_tag.site_token, video_tag.uid)
    end
  end

  def perform(site_token, uid)
    if video_tag = VideoTag.where(site_token: site_token, uid: uid).first
      VideoTagDuplicateRemover.new(video_tag).remove_duplicate
      Librato.increment 'video_tag.remove_duplicate'
    end
  end
end
