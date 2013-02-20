require 'video_tag_updater'

class VideoTagMigrator
  attr_reader :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
  end

  def migrate
    freeze_updated_at do
      attributes = video_tag.attributes
      attributes['sources'] = sources
      VideoTagUpdater.new(video_tag).update(attributes)
    end
  end

  private

  def sources
    return nil unless video_tag.sources.empty?
    video_tag.current_sources.map do |source_crc32|
      video_tag.read_attribute(:sources)[source_crc32]
    end
  end

  def freeze_updated_at
    updated_at = video_tag.updated_at
    yield
    video_tag.update_column(:updated_at, updated_at)
  end

end
