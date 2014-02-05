require 'quanto'

class FitbitKeyController < ApplicationController
  def create
    puts "Quanto user: #{session[:quanto_user_id]}"
    auth = request.env["omniauth.auth"]
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      token_secret: auth.credentials.secret,
      plugin: 'fitbit',
    })
    key.save!

    quanto_key = OauthKey.where(provider: 'quanto', plugin: 'fitbit').last
    client = Quanto::Client.new(ENV["QUANTO_KEY"], ENV["QUANTO_SECRET"], access_token: quanto_key.token)
    redirect_to client.plugin_url
  end
end
