##
# Publisher model represents the publisher of a publication
#
# Publishers can be associated with multiple podcasts through a many-to-many relationship.
# This allows for proper attribution of source materials and publication information.
#
# @attr [String] name - The name of the publishing company or entity
# @attr [DateTime] created_at - When the publisher record was created
# @attr [DateTime] updated_at - When the publisher record was last updated
#
class Publisher < ApplicationRecord
  # Many-to-many relationship with podcasts
  has_and_belongs_to_many :podcasts

  # Validations
  validates :name, presence: true, uniqueness: true

  ##
  # Get the count of podcasts associated with this publisher
  #
  # @return [Integer] number of associated podcasts
  #
  delegate :count, to: :podcasts, prefix: true

  ##
  # Scope for finding publishers by name (case-insensitive)
  #
  # @param [String] name_query - The name to search for
  # @return [ActiveRecord::Relation] publishers matching the name query
  #
  scope :by_name, ->(name_query) {
    where('name ILIKE ?', "%#{name_query}%")
  }
end
