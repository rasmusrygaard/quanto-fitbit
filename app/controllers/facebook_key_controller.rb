class FacebookKeyController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      token_secret: auth.credentials.secret,
      plugin: 'facebook',
    })
    key.save!

    quanto_key = Mapping.create_mapping_for_key(key, session)

    client = Quanto::Client.new(ENV["QUANTO_FACEBOOK_KEY"], ENV["QUANTO_FACEBOOK_SECRET"],
        access_token: quanto_key.token)
    redirect_to client.plugin_url
  end
end