class Mapping < ActiveRecord::Base

  scope :lastfm, -> { where(provider: :lastfm) }
  scope :fitbit, -> { where(provider: :fitbit) }
  scope :instagram, -> { where(provider: :instagram) }

  belongs_to :quanto_key, class_name: 'OauthKey'
  belongs_to :api_key, class_name: 'OauthKey'

  # Store the mapping between different types of keys. It does so by looking up the current
  # :quanto_key_id in the session (which is later removed), and storing the API key as the API
  # key for the corresponding mapping.
  # Returns the QuantoKey newly associated with the API key.
  def self.create_mapping_for_key(api_key, session)
    mapping = Mapping.where(quanto_key_id: session[:quanto_key_id]).last
    mapping.api_key = api_key
    mapping.provider = api_key.provider
    mapping.save!
    session.delete(:quanto_key_id)
    mapping.quanto_key
  end

end
