require 'sublime_video_private_api'

class VideoStat
  include SublimeVideoPrivateApi::Model
  uses_private_api :stats
  collection_path '/private_api/sites/:site_token/videos/:video_uid/video_stats'

  def self.last_days_starts(video_tag, days)
    result = get_raw(:last_days_starts, _site_token: video_tag.site_token, _video_uid: video_tag.uid, days: days)
    result[:parsed_data][:data][:starts]
  end
end
