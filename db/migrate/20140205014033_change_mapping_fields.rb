class ChangeMappingFields < ActiveRecord::Migration
  def up
    drop_table :mappings

    create_table :mappings do |t|
      t.integer :quanto_key_id
      t.integer :api_key_id

      t.timestamps
    end

    add_column :oauth_keys, :mapping_id, :integer
  end

  def down
    drop_table :mappings
    create_table :mappings do |t|
      t.string :fitbit_token
      t.string :fitbit_token_secret
      t.string :quanto_access_token

      t.timestamps
    end

    remove_column :oauth_keys, :mapping_id
  end
end
