##
# User model handles authentication and content ownership
#
# Users can create podcasts and favorite podcasts created by others.
# Authentication is handled by Devise with email/password.
#
# @attr [String] email - User's email address (unique, validated by Devise)
# @attr [String] encrypted_password - Encrypted password (handled by Devise)
# @attr [DateTime] created_at - When the user was created
# @attr [DateTime] updated_at - When the user was last updated
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # A user can create many podcasts
  has_many :podcasts, dependent: :destroy

  # A user can favorite many podcasts through the favorites join table
  has_many :favorites, dependent: :destroy
  has_many :favorited_podcasts, through: :favorites, source: :podcast

  ##
  # Check if the user has favorited a specific podcast
  #
  # @param [Podcast] podcast - The podcast to check
  # @return [Boolean] true if favorited, false otherwise
  #
  def favorited?(podcast)
    favorited_podcasts.include?(podcast)
  end

  ##
  # Add a podcast to the user's favorites
  #
  # @param [Podcast] podcast - The podcast to favorite
  # @return [Favorite] the created favorite record
  #
  def favorite!(podcast)
    favorites.create!(podcast: podcast)
  end

  ##
  # Remove a podcast from the user's favorites
  #
  # @param [Podcast] podcast - The podcast to unfavorite
  # @return [Boolean] true if successfully removed
  #
  def unfavorite!(podcast)
    favorites.find_by(podcast: podcast)&.destroy
  end
end
