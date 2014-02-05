class Mapping < ActiveRecord::Base

  belongs_to :quanto_key, class_name: 'OauthKey'
  belongs_to :api_key, class_name: 'OauthKey'

end
