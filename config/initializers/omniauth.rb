Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, ENV["FITBIT_KEY"], ENV["FITBIT_SECRET"]
  provider :lastfm, ENV["LAST_FM_KEY"], ENV["LAST_FM_SECRET"]
  # Register all keys for quanto
  [:fitbit, :lastfm].each do |provider|
    provider(:quanto, ENV["QUANTO_#{provider.upcase}_KEY"], ENV["QUANTO_#{provider.upcase}_SECRET"],
             request_path: "/auth/quanto/#{provider}", callback_path: "/auth/quanto/#{provider}/callback")
  end
end
