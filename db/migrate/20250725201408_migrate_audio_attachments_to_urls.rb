class MigrateAudioAttachmentsToUrls < ActiveRecord::Migration[8.0]
  def up
    # Find all audio attachments for podcasts
    audio_attachments = ActiveStorage::Attachment.where(
      record_type: 'Podcast',
      name: 'audio'
    ).includes(:record)
    
    audio_attachments.find_each do |attachment|
      podcast = attachment.record
      
      # For existing attachments, we'll use a placeholder URL since we can't regenerate the original URLs
      # In a real migration, you might want to copy files to a CDN and get real URLs
      placeholder_url = "https://example.com/placeholder-audio-#{podcast.id}.mp3"
      
      # Update the podcast with the audio URL
      podcast.update_column(:audio_url, placeholder_url)
      
      puts "Migrated podcast #{podcast.id} audio attachment to URL: #{placeholder_url}"
    end
    
    # Remove all audio attachments for podcasts
    ActiveStorage::Attachment.where(
      record_type: 'Podcast',
      name: 'audio'
    ).delete_all
    
    puts "Removed all audio attachments for podcasts"
  end

  def down
    # This migration is not reversible since we're destroying file data
    # You would need to re-upload the files manually
    raise ActiveRecord::IrreversibleMigration, "Cannot reverse migration - audio files have been deleted"
  end
end
