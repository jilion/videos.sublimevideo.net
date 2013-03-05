require 'sidekiq'
require 'librato-rails'

require 'video_tag_data_unaliaser'
require 'video_tag_duplicate_remover_worker'
require 'video_tag_updater'

class VideoTagUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(site_token, uid, data)
    unaliased_data = VideoTagDataUnaliaser.unalias(data)
    video_tag = VideoTag.find_or_initialize(site_token: site_token, uid: uid)
    VideoTagUpdater.new(video_tag).update(unaliased_data)
    VideoTagDuplicateRemoverWorker.perform_async_if_needed(video_tag)
    # PusherWrapper.trigger("private-#{video_tag.site.token}", 'video_tag')
    # PusherWrapper.trigger("private-#{video_tag.site.token}", 'video_tag', video_tag.backbone_data)
    Librato.increment 'video_tag.update'
  end
end
