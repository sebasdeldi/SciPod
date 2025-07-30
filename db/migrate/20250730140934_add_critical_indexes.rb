class AddCriticalIndexes < ActiveRecord::Migration[8.0]
  def up
    # ===================================================================
    # 🚨 CRITICAL - MUST HAVE (Fixing major performance bottlenecks)
    # ===================================================================
    
    # Join table indexes for authors_podcasts (used by pg_search)
    # WITHOUT these: Every search query scans entire join table!
    add_index :authors_podcasts, :podcast_id, name: 'idx_authors_podcasts_podcast_id'
    add_index :authors_podcasts, :author_id, name: 'idx_authors_podcasts_author_id'
    add_index :authors_podcasts, [:podcast_id, :author_id], name: 'idx_authors_podcasts_composite', unique: true
    
    # Join table indexes for podcasts_publishers 
    # WITHOUT these: Search queries with publishers will be slow
    add_index :podcasts_publishers, :podcast_id, name: 'idx_podcasts_publishers_podcast_id'
    add_index :podcasts_publishers, :publisher_id, name: 'idx_podcasts_publishers_publisher_id'
    add_index :podcasts_publishers, [:podcast_id, :publisher_id], name: 'idx_podcasts_publishers_composite', unique: true
    
    # ===================================================================
    # 🔥 HIGH PRIORITY (Solving frequent slow queries from logs)
    # ===================================================================
    
    # Category filtering - logs show "categories"."id" = 5 queries
    add_index :categories_podcasts, :category_id, name: 'idx_categories_podcasts_category_id'
    
    # Favorites performance - logs show 21.8ms favorites query!
    add_index :favorites, [:user_id, :created_at], name: 'idx_favorites_user_created_at'
    add_index :favorites, [:podcast_id, :created_at], name: 'idx_favorites_podcast_created_at'
    
    # Cursor pagination - logs show WHERE (podcasts.id < '116') ORDER BY id DESC
    add_index :podcasts, [:status, :id], name: 'idx_podcasts_status_id_desc', order: { id: :desc }
    
    # ===================================================================
    # 📊 MEDIUM PRIORITY (Common patterns, good to have)
    # ===================================================================
    
    # Author name searches (used in pg_search)
    add_index :authors, :name, name: 'idx_authors_name'
    
    # Common podcast filtering patterns
    add_index :podcasts, [:status, :created_at], name: 'idx_podcasts_status_created_at'
    add_index :podcasts, [:user_id, :status], name: 'idx_podcasts_user_status'
    add_index :podcasts, :created_at, name: 'idx_podcasts_created_at'
    add_index :podcasts, [:user_id, :id], name: 'idx_podcasts_user_id_desc', order: { id: :desc }
    
    # ===================================================================
    # 🔍 SEARCH OPTIMIZATION (Full-text search performance)
    # ===================================================================
    
    # GIN indexes for pg_search - these are specialized for text search
    execute "CREATE INDEX idx_podcasts_search_title ON podcasts USING gin(to_tsvector('english', title))"
    execute "CREATE INDEX idx_podcasts_search_issn ON podcasts USING gin(to_tsvector('english', coalesce(issn, '')))"
    execute "CREATE INDEX idx_podcasts_search_doi ON podcasts USING gin(to_tsvector('english', coalesce(doi, '')))"
    execute "CREATE INDEX idx_authors_search_name ON authors USING gin(to_tsvector('english', name))"
    
    # ===================================================================
    # 🛡️ DATA INTEGRITY (Important for data consistency)
    # ===================================================================
    
    # Foreign key constraints (prevent orphaned records)
    add_foreign_key :authors_podcasts, :podcasts, on_delete: :cascade
    add_foreign_key :authors_podcasts, :authors, on_delete: :cascade
    add_foreign_key :podcasts_publishers, :podcasts, on_delete: :cascade
    add_foreign_key :podcasts_publishers, :publishers, on_delete: :cascade
  end

  def down
    # Remove foreign keys first
    remove_foreign_key :authors_podcasts, :podcasts
    remove_foreign_key :authors_podcasts, :authors
    remove_foreign_key :podcasts_publishers, :podcasts
    remove_foreign_key :podcasts_publishers, :publishers
    
    # Remove GIN indexes
    execute "DROP INDEX IF EXISTS idx_podcasts_search_title"
    execute "DROP INDEX IF EXISTS idx_podcasts_search_issn"
    execute "DROP INDEX IF EXISTS idx_podcasts_search_doi"
    execute "DROP INDEX IF EXISTS idx_authors_search_name"
    
    # Remove regular indexes
    remove_index :authors_podcasts, name: 'idx_authors_podcasts_podcast_id'
    remove_index :authors_podcasts, name: 'idx_authors_podcasts_author_id'
    remove_index :authors_podcasts, name: 'idx_authors_podcasts_composite'
    remove_index :podcasts_publishers, name: 'idx_podcasts_publishers_podcast_id'
    remove_index :podcasts_publishers, name: 'idx_podcasts_publishers_publisher_id'
    remove_index :podcasts_publishers, name: 'idx_podcasts_publishers_composite'
    remove_index :authors, name: 'idx_authors_name'
    remove_index :podcasts, name: 'idx_podcasts_status_created_at'
    remove_index :podcasts, name: 'idx_podcasts_user_status'
    remove_index :podcasts, name: 'idx_podcasts_created_at'
    remove_index :podcasts, name: 'idx_podcasts_status_id_desc'
    remove_index :podcasts, name: 'idx_podcasts_user_id_desc'
    remove_index :favorites, name: 'idx_favorites_user_created_at'
    remove_index :favorites, name: 'idx_favorites_podcast_created_at'
    remove_index :categories_podcasts, name: 'idx_categories_podcasts_category_id'
  end
end
