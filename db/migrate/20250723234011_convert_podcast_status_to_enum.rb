class ConvertPodcastStatusToEnum < ActiveRecord::Migration[8.0]
  def up
    # Create the enum type in PostgreSQL
    execute <<-SQL
      CREATE TYPE podcast_status AS ENUM (
        'processing',
        'ready', 
        'error',
        'cancelled'
      );
    SQL

    # Add a new column with the enum type
    add_column :podcasts, :new_status, :podcast_status, default: 'processing', null: false

    # Copy existing values, converting integers to enum strings
    execute <<-SQL
      UPDATE podcasts SET new_status = 
        CASE status
          WHEN 0 THEN 'processing'::podcast_status
          WHEN 1 THEN 'ready'::podcast_status
          WHEN 2 THEN 'error'::podcast_status
          WHEN 3 THEN 'cancelled'::podcast_status
          ELSE 'processing'::podcast_status
        END;
    SQL

    # Remove the old integer column and rename the new one
    remove_column :podcasts, :status
    rename_column :podcasts, :new_status, :status
    
    # Re-add the index on the new status column
    add_index :podcasts, :status
  end

  def down
    # Remove the index
    remove_index :podcasts, :status
    
    # Add back the integer column
    add_column :podcasts, :new_status, :integer, default: 0, null: false

    # Convert enum values back to integers
    execute <<-SQL
      UPDATE podcasts SET new_status = 
        CASE status
          WHEN 'processing' THEN 0
          WHEN 'ready' THEN 1
          WHEN 'error' THEN 2
          WHEN 'cancelled' THEN 3
          ELSE 0
        END;
    SQL

    # Remove the enum column and rename the integer one
    remove_column :podcasts, :status
    rename_column :podcasts, :new_status, :status
    
    # Re-add the index
    add_index :podcasts, :status
    
    # Drop the enum type
    execute "DROP TYPE podcast_status;"
  end
end
