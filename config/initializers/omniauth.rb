Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, 'c42a6a7099f54e0ab9146fa355604a14', '01371805cee6429da70c5dab1f3d1705'
  provider :quanto, 'd9e1c99976f8a1587f5a6815f6f0581a4ca8fd1fc4e432f43d9c08640eafe9ad', '7d53ec7c6ed77cd91b4cbd16565903d562737fcdec1e515e39c60eecd9fda13c'
end
