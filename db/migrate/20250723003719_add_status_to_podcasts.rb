class AddStatusToPodcasts < ActiveRecord::Migration[8.0]
  def change
    add_column :podcasts, :status, :integer, default: 0, null: false
    add_column :podcasts, :status_details, :string, null: true
    
    add_index :podcasts, :status
  end
end
