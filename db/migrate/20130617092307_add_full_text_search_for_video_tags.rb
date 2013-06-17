class AddFullTextSearchForVideoTags < ActiveRecord::Migration
  def change
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    execute "CREATE EXTENSION IF NOT EXISTS unaccent;"
    execute "create index on video_tags using gin(to_tsvector('english', title));"
  end
end
