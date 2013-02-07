namespace :migrate do

  desc "Migrate video_tags attributes"
  task video_tags: :environment do
    VideoTag.all.find_each do |video_tag|
      VideoTagMigrator.new(video_tag).migrate
    end
  end

end
