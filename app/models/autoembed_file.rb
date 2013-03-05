require 'active_support/core_ext'
require 'tempfile'

class AutoEmbedFile < Tempfile
  attr_accessor :video_tag, :tempfile

  delegate :site_token, :title, :poster_url, to: :video_tag

  def initialize(video_tag)
    @video_tag = video_tag
    super("autoembed.html", Rails.root.join('tmp'))
    write_from_template
  end

  private

  def write_from_template
    template = ERB.new(File.new(template_path).read)
    self.write template.result(binding)
    self.rewind
  end

  def template_path
    Rails.root.join('app', 'templates', "autoembed.html.erb")
  end

  def data_settings
    video_tag.settings.map { |k,v| "#{k.dasherize}: #{v}" }.join('; ')
  end

  def sources
    video_tag.sources.map { |source|
      ["<source src=\"#{source.url}\""].tap { |array|
        array << 'data-quality="hd"' if source.quality == 'hd'
        array << '/>'
      }.join(" ")
    }.join('\n')
  end
end
