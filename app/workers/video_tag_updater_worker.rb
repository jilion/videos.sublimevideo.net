require 'sidekiq'
require 'librato-rails'

require 'site_token'
require 'video_tag_data_unaliaser'
require 'video_tag_updater'
require 'video_tag_duplicate_remover_worker'
require 'autoembed_file_uploader_worker'

class VideoTagUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(site_token, uid, data)
    unless site_token == SiteToken[:my]
      unaliased_data = VideoTagDataUnaliaser.unalias(data)
      video_tag = VideoTag.find_or_initialize(site_token: site_token, uid: uid)
      VideoTagUpdater.new(video_tag).update(unaliased_data)
      VideoTagDuplicateRemoverWorker.perform_async_if_needed(video_tag)
      AutoEmbedFileUploaderWorker.perform_async_if_needed(video_tag)
      Librato.increment 'video_tag.update'
    end
  end
end
