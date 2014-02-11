require 'quanto'

class ManualKeyController < ApplicationController

  def create
    key = OauthKey.create({
      provider: 'manual',
      uid: 1, # TODO: Change to actual ID.
      plugin: 'manual',
    })
    key.save!

    quanto_key = Mapping.create_mapping_for_key(key, session)

    client = Quanto::Client.new(ENV["QUANTO_FITBIT_KEY"], ENV["QUANTO_FITBIT_SECRET"],
                                access_token: quanto_key.token)
    redirect_to client.plugin_url
  end

end
