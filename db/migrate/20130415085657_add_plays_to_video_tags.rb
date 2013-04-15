class AddPlaysToVideoTags < ActiveRecord::Migration
  def change
    add_column :video_tags, :plays, :integer, array: true, default: "{#{365.times.map { '0' }.join(',')}}"
  end
end
