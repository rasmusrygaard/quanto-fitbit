class OauthKey < ActiveRecord::Base

  belongs_to :user
  has_one :mapping

  # Define some convenient scopes to easily access certain keys
  scope :quanto, -> { where(provider: :quanto) }
  scope :fitbit, -> { where(provider: :fitbit) }

end
