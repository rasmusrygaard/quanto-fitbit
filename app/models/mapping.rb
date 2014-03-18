class Mapping < ActiveRecord::Base

  scope :twitter, -> { where(provider: :twitter).valid }
  scope :instagram, -> { where(provider: :instagram).valid }
  scope :facebook, -> { where(provider: :facebook).valid }
  scope :fitbit, -> { where(provider: :fitbit).valid }
  scope :lastfm, -> { where(provider: :lastfm).valid }
  scope :manual, -> { where(provider: :manual).valid }
  scope :moves, -> { where(provider: :moves).valid }
  scope :valid, -> { where(revoked: false) }

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

    fill_data(mapping)

    session.delete(:quanto_key_id)
    mapping.quanto_key
  end

  def invalidate!
    self.revoked = true
    save!
  end

  def invalid?
    self.revoked
  end

  def self.fill_data(mapping)
    case mapping.provider
    when 'facebook'
      FacebookWorker.perform_async(mapping.id)
    when 'fitbit'
      FitbitWorker.perform_async(mapping.id, true)
    when 'instagram'
      InstagramWorker.perform_async(mapping.id)
    when 'lastfm'
      LastfmWorker.perform_async(mapping.id)
    when 'twitter'
      TwitterWorker.perform_async(mapping.id)
    when 'moves'
      MovesWorker.perform_async(mapping.id)
    end
  end

end
