class CreateVideoSources < ActiveRecord::Migration
  def change
    create_table :video_sources do |t|
      t.references :video_tag, null: false, index: true
      t.string :url, null: false
      t.string :quality, null: false
      t.string :family, null: false
      t.string :resolution

      t.timestamps
    end
  end
end
