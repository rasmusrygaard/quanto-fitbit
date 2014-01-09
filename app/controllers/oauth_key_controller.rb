class OauthKeyController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    puts auth
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.oauth_token,
      token_secret: auth.oauth_token_secret
    })
    puts key
    key.save!
    render json: 'ok!', status: 200
  end

end
