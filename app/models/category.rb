##
# Category model represents podcast categories for organizing content
#
# Categories have a unique name and can be associated with multiple podcasts.
# This is a many-to-many relationship through a join table.
#
# @attr [String] name - The unique name of the category
# @attr [DateTime] created_at - When the category was created
# @attr [DateTime] updated_at - When the category was last updated
#
class Category < ApplicationRecord
  # Many-to-many relationships
  has_and_belongs_to_many :podcasts

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :name, length: { minimum: 2, maximum: 50 }

  # Normalize name before saving (remove extra spaces and proper case)
  before_save :normalize_name

  # Scopes
  scope :alphabetical, -> { order(:name) }

  private

  ##
  # Normalize the category name before saving
  # Strips whitespace and ensures consistent formatting
  #
  def normalize_name
    self.name = name.strip.titleize if name.present?
  end
end
