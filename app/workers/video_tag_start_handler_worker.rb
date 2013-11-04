require 'sidekiq'

require 'site_token'

class VideoTagStartHandlerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'videos'

  def perform(site_token, uid, data)
    duration = data['vd'].to_i.in?(0..2147483647) ? data['vd'].to_i : nil
    VideoTag.where(site_token: site_token, uid: uid).update_columns(
      started_at: Time.parse(data['t']).utc,
      duration: duration
    )
  end
end
