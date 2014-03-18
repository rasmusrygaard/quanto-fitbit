class LastfmKeyController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    key = OauthKey.new({
      provider: auth.provider,
      uid: auth.uid,
      token: auth.credentials.token,
      plugin: 'lastfm',
    })
    key.save!

    quanto_key = Mapping.create_mapping_for_key(key, session)

    client = Quanto::Client.new(ENV["QUANTO_LASTFM_KEY"], ENV["QUANTO_LASTFM_SECRET"],
                                access_token: quanto_key.token)
    redirect_to client.activate_plugin
  end

end
