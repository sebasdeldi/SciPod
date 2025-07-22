##
# Favorite model represents a join table connecting Users to Podcasts they have "liked"
#
# This model enforces that a specific user can only favorite a specific podcast once.
# It provides the many-to-many relationship between users and their favorited podcasts.
#
# @attr [Integer] user_id - Foreign key to the user who favorited
# @attr [Integer] podcast_id - Foreign key to the favorited podcast
# @attr [DateTime] created_at - When the favorite was created
# @attr [DateTime] updated_at - When the favorite was last updated
#
class Favorite < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :podcast

  # Validations
  validates :user_id, uniqueness: { scope: :podcast_id, message: "has already favorited this podcast" }

  ##
  # Scope for finding favorites by a specific user
  #
  # @param [User] user - The user to filter by
  # @return [ActiveRecord::Relation] favorites belonging to the user
  #
  scope :by_user, ->(user) { where(user: user) }

  ##
  # Scope for finding favorites for a specific podcast
  #
  # @param [Podcast] podcast - The podcast to filter by
  # @return [ActiveRecord::Relation] favorites for the podcast
  #
  scope :for_podcast, ->(podcast) { where(podcast: podcast) }

  ##
  # Scope for ordering by most recently favorited
  #
  # @return [ActiveRecord::Relation] favorites ordered by creation date (newest first)
  #
  scope :recent, -> { order(created_at: :desc) }
end
