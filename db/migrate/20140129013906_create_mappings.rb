class CreateMappings < ActiveRecord::Migration
  def change
    create_table :mappings do |t|
      t.string :fitbit_token
      t.string :fitbit_token_secret
	  t.string :quanto_access_token
	  
      t.timestamps
    end
  end
end
