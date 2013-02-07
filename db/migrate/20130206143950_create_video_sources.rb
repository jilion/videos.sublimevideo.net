class CreateVideoSources < ActiveRecord::Migration
  def change
    create_table :video_sources do |t|
      t.references :video_tag, null: false, index: true
      t.text :url, null: false
      t.string :quality
      t.string :family
      t.string :resolution
      t.integer :position

      t.timestamps
    end
  end
end
