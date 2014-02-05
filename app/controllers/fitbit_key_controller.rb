require 'quanto'

class FitbitKeyController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      token_secret: auth.credentials.secret,
      plugin: 'fitbit',
    })
    key.save!

    # Store the mapping between different types of keys.
    mapping = Mapping.where(quanto_key_id: session[:quanto_key_id]).last
    mapping.api_key = key
    mapping.save!
    session.delete(:quanto_key_id)

    quanto_key = OauthKey.where(provider: 'quanto', plugin: 'fitbit').last
    client = Quanto::Client.new(ENV["QUANTO_KEY"], ENV["QUANTO_SECRET"], access_token: quanto_key.token)
    redirect_to client.plugin_url
  end
end
