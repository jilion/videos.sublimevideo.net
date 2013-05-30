class AddStartsToVideoTags < ActiveRecord::Migration
  def change
    add_column :video_tags, :starts, :integer, array: true, default: "{#{365.times.map { '0' }.join(',')}}"
    add_column :video_tags, :starts_updated_at, :datetime

    add_index :video_tags, :updated_at
    add_index :video_tags, :starts_updated_at
  end
end
