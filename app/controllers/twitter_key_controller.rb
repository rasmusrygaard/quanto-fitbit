class TwitterKeyController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      token_secret: auth.credentials.secret,
      plugin: 'twitter',
    })
    key.save!

    quanto_key = Mapping.create_mapping_for_key(key, session)

    client = Quanto::Client.new(ENV["QUANTO_TWITTER_KEY"], ENV["QUANTO_TWITTER_SECRET"],
        access_token: quanto_key.token)
    redirect_to client.activate_plugin
  end
end
