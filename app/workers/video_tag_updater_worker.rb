require 'sidekiq'
require 'librato-rails'

require 'video_tag_data_unaliaser'
require 'video_tag_duplicate_remover'
require 'video_tag_updater'

class VideoTagUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(site_token, uid, data)
    unaliased_data = VideoTagDataUnaliaser.unalias(data)
    video_tag = VideoTag.find_or_initialize(site_token: site_token, uid: uid)
    VideoTagUpdater.new(video_tag).update(unaliased_data)
    VideoTagDuplicateRemover.new(video_tag).remove_duplicate
    # PusherWrapper.trigger("private-#{video_tag.site.token}", 'video_tag')
    Librato.increment 'video_tag.update'
  end
end
