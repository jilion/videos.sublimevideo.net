class VideoTagDuplicateRemover
  attr_reader :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def remove_duplicate
    if video_tag.saved_once? && video_tag.valid_uid?
      if video_tag_duplicate = find_duplicate
        VideoStatsMergerWorker.perform_async(video_tag.site_token, video_tag.uid, video_tag_duplicate.uid)
        video_tag_duplicate.destroy
        Librato.increment 'video_tag.duplicate_removed'
      end
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
