# require 'omniauth-quanto'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, 'c42a6a7099f54e0ab9146fa355604a14', '01371805cee6429da70c5dab1f3d1705'
  provider :quanto, '41921b6f76e3dbf0c5f85b0dc672cc43cb89705ee9db0ab4f3808b45cef68856', '9ab40d6e0350ba00f9e45ff039af1308a1ed26d8aa35383b16115a3bc47f6c7b'
end

puts OmniAuth::Strategies.constants
