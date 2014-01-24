  class FitbitKeyController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
    })
    key.save!
    redirect_to 'http://quanto.herokuapp.com/plugins/1'
  end
end
