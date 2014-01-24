class OauthKeyController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    binding.pry
    puts '-------------------------------------------------------'
    puts auth.inspect
    puts '-------------------------------------------------------'
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
