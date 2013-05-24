namespace :duplication do
  desc "Merge video_tag with same url base (but with dynamic params) site_token=wuzqby9u"
  task custom_merge: :environment do
    VideoTag.where(site_token: 'wuzqby9u', uid_origin: 'attribute').includes(:sources).all.each do |video_tag|
      if source = video_tag.sources.first
        video_url = source.url.match(/^([^\?]*)/)[1]
        relation = VideoTag.includes(:sources).where(site_token: 'wuzqby9u', uid_origin: 'source').where("url LIKE '#{video_url}%'").all
        relation.each do |video_tag_duplicate|
          VideoStatsMergerWorker.perform_async(video_tag.site_token, video_tag.uid, video_tag_duplicate.uid)
          video_tag_duplicate.destroy
        end
      end
    end
  end
end
