namespace :duplication do
  desc "Merge video_tag with same url base (but with dynamic params) site_token=wuzqby9u"
  task custom_merge: :environment do
    VideoTag.where(site_token: 'wuzqby9u', uid_origin: 'attribute').includes(:sources).all do |video_tag|
      if source = video_tag.sources.first
        video_url = source.url.match(/^(.*)\?/)[1]
        if video_tag_duplicate = VideoTag.joins(:sources).where(site_token: 'wuzqby9u', uid_origin: 'source').where("url LIKE '#{video_url}%'").first
          puts "#{video_tag.uid} :: #{video_tag_duplicate.uid}"
        else
          puts "#{video_tag.uid} :: ---"
        end
      end
    end
  end
end
