require 'sidekiq'

require 'site_token'

class VideoTagDurationUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(site_token, uid, duration)
    unless site_token == SiteToken[:my]
      duration = duration.to_i.in?(0..2147483647) ? duration.to_i : nil
      VideoTag.where(site_token: site_token, uid: uid).update_all(duration: duration)
      Librato.increment 'video_tag.duration.update'
    end
  end
end
