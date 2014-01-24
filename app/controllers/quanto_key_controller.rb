class QuantoKeyController < ApplicationController

  # The callback URL will be of the form /auth/quanto_XXX/callback where XXX is the name of a third
  # party provider. For instance, the callback for the Fitbit plugin should be
  # /auth/quanto_fitbit/callback. We can use this string to detect which plugin was authorized.
  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.create({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
    })
    key.save!

    case params[:provider].to_sym
    when :fitbit
      redirect_to '/auth/fitbit'
    end
  end

end
