class CreateVideoTags < ActiveRecord::Migration
  def change
    execute "create extension hstore"
    create_table :video_tags do |t|
      t.string :site_token, null: false
      t.string  :uid, null: false
      t.string  :uid_origin, null: false, default: 'attribute'

      t.string  :title
      t.string  :title_origin
      t.string  :sources_id
      t.string  :sources_origin
      t.text    :poster_url
      t.string  :size
      t.integer :duration # ms

      t.hstore  :settings
      t.hstore  :options

      t.timestamps
    end

    add_index :video_tags, [:site_token, :uid], unique: true
    add_index :video_tags, [:site_token, :updated_at]
  end
end
