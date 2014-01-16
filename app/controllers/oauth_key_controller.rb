class OauthKeyController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    puts auth.inspect
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      token_secret: auth.credentials.secret,
    })
    key.save!
    render json: 'ok!', status: 200
  end

end
