class AddPluginToOauthKey < ActiveRecord::Migration
  def change
    add_column :oauth_keys, :plugin, :string
  end
end
