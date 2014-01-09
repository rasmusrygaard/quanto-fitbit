Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, 'c42a6a7099f54e0ab9146fa355604a14', '01371805cee6429da70c5dab1f3d1705'
end
