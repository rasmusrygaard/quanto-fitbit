class CreateOauthKeys < ActiveRecord::Migration
  def change
    create_table :oauth_keys do |t|
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end
