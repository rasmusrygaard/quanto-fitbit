require "instagram"

Instagram.configure do |config|
  config.client_id = ENV["INSTAGRAM_KEY"]
  config.access_token = ENV["INSTAGRAM_KEY"]
end
