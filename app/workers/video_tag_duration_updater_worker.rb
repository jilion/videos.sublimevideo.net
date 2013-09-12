require 'sidekiq'

require 'site_token'

class VideoTagDurationUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(site_token, uid, duration)
    unless site_token == SiteToken[:my]
      VideoTag.where(site_token: site_token, uid: uid).update_all(duration: duration)
      Librato.increment 'video_tag.duration.update'
    end
  end
end
