class AddStartsToVideoTags < ActiveRecord::Migration
  def change
    add_column :video_tags, :starts, :integer, array: true, default: "{#{365.times.map { '0' }.join(',')}}"
    add_column :video_tags, :last_30_days_starts, :integer, default: 0
    add_column :video_tags, :last_90_days_starts, :integer, default: 0
    add_column :video_tags, :last_365_days_starts, :integer, default: 0

    add_column :video_tags, :loaded_at, :datetime
    add_column :video_tags, :starts_updated_at, :datetime

    remove_index :video_tags, [:site_token, :updated_at]
    add_index :video_tags, [:site_token, :loaded_at]
    add_index :video_tags, :loaded_at
    add_index :video_tags, :starts_updated_at
    add_index :video_tags, [:site_token, :last_30_days_starts]
    add_index :video_tags, [:site_token, :last_90_days_starts]
    add_index :video_tags, [:site_token, :last_365_days_starts]
  end
end
