class OauthKeyController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    key = OathKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.oauth_token,
      token_secret: auth.oauth_token_secret
    })
    key.save!
    render json: 'ok!'
  end

end
