# require 'omniauth-quanto'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, 'c42a6a7099f54e0ab9146fa355604a14', '01371805cee6429da70c5dab1f3d1705'
  provider :quanto, '90e41283b1c888e8993bf75cea806caef6ae7bf9fb67b9ebed39eff8e4ab6187', 'f9900c9cbb2b26e384a4998d76bdfef6053554d59127a9993ddb86aa49a6eec0'
end

puts OmniAuth::Strategies.constants
