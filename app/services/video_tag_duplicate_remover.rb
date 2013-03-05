require 'active_support/core_ext'

require 'video_stats_merger_worker'

class VideoTagDuplicateRemover
  attr_reader :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def remove_duplicate
    if video_tag_duplicate = find_duplicate
      VideoStatsMergerWorker.perform_async(video_tag.site_token, video_tag.uid, video_tag_duplicate.uid)
      video_tag_duplicate.destroy
    end
  end

  private

  def find_duplicate
    if video_tag.sources_id?
      VideoTag.duplicates_sources_id(video_tag).first
    elsif video_tag.first_source.present?
      VideoTag.duplicates_first_source_url(video_tag).first
    end
  end

end
