Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, ENV["FITBIT_KEY"], ENV["FITBIT_SECRET"]
  provider :quanto, ENV["QUANTO_KEY"], ENV["QUANTO_SECRET"], request_path: '/auth/quanto/fitbit', callback_path: '/auth/quanto/fitbit/callback'
end
