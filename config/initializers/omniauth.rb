Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, ENV["FITBIT_KEY"], ENV["FITBIT_SECRET"]
  provider :lastfm, ENV["LASTFM_KEY"], ENV["LASTFM_SECRET"]
  provider :instagram, ENV["INSTAGRAM_KEY"], ENV["INSTAGRAM_SECRET"]
  provider :facebook, ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"], { :scope => "user_status"}
  provider :moves, ENV["MOVES_KEY"], ENV["MOVES_SECRET"], { :scope => "activity location"}
  provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]

  # Register all keys for quanto
  [:fitbit, :lastfm, :instagram, :facebook, :moves, :twitter, :manual].each do |provider_name|
    provider(:quanto, ENV["QUANTO_#{provider_name.upcase}_KEY"], ENV["QUANTO_#{provider_name.upcase}_SECRET"],
             request_path: "/auth/quanto/#{provider_name}", callback_path: "/auth/quanto/#{provider_name}/callback")
  end
end
