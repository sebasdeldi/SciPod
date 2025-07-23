##
# Author model represents an author of a publication
#
# Authors can be associated with multiple podcasts through a many-to-many relationship.
# This allows for proper attribution of source materials.
#
# @attr [String] name - The full name of the author
# @attr [DateTime] created_at - When the author record was created
# @attr [DateTime] updated_at - When the author record was last updated
#
class Author < ApplicationRecord
  # Many-to-many relationship with podcasts
  has_and_belongs_to_many :podcasts

  # Validations
  validates :name, presence: true, uniqueness: true

  ##
  # Get the count of podcasts associated with this author
  #
  # @return [Integer] number of associated podcasts
  #
  delegate :count, to: :podcasts, prefix: true

  ##
  # Scope for finding authors by name (case-insensitive)
  #
  # @param [String] name_query - The name to search for
  # @return [ActiveRecord::Relation] authors matching the name query
  #
  scope :by_name, ->(name_query) {
    where('name ILIKE ?', "%#{name_query}%")
  }
end
