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

    quanto_plugin_id = OauthKey.where(provider: 'quanto', plugin: 'fitbit').pluck(:uid).last
    redirect_to "http://quanto.herokuapp.com/applications/#{quanto_plugin_id}/plugin"
  end
end
