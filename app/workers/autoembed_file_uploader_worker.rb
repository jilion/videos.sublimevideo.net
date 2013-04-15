require 'sidekiq'
require 'librato-rails'

require 'autoembed_file_manager'

class AutoEmbedFileUploaderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def self.perform_async_if_needed(video_tag)
    if video_tag.options && video_tag.options['autoembed'] == true
      perform_async(video_tag.site_token, video_tag.uid)
    end
  end

  def perform(site_token, uid)
    if video_tag = VideoTag.where(site_token: site_token, uid: uid).first
      AutoEmbedFileManager.new(video_tag).upload
      Librato.increment 'video_tag.autoembed.uploads'
    end
  end
end
