class User < ActiveRecord::Base

  has_many :oauth_keys

end
