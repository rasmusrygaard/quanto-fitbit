class QuantoKeyController < ApplicationController

  # The callback URL will be of the form /auth/quanto_XXX/callback where XXX is the name of a third
  # party provider. For instance, the callback for the Fitbit plugin should be
  # /auth/quanto_fitbit/callback. We can use this string to detect which plugin was authorized.
  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.create!({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      plugin: params[:provider],
    })

    mapping = Mapping.create!(quanto_key: key)
    session[:quanto_key_id] = key.id

    case params[:provider].to_sym
    when :fitbit
      redirect_to '/auth/fitbit'
    when :lastfm
      redirect_to '/auth/lastfm'
    when :instagram
      redirect_to '/auth/instagram'
    when :facebook
      redirect_to '/auth/facebook'
    when :moves
      redirect_to '/auth/moves'
    when :twitter
      redirect_to '/auth/twitter'
    when :manual
      redirect_to '/auth/manual/callback'
    end
  end

end
