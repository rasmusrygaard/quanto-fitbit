class AddTokenToOauthKey < ActiveRecord::Migration
  def change
    add_column :oauth_keys, :token, :string
    add_column :oauth_keys, :token_secret, :string
  end
end
