class AddInvalidatedFieldToMappings < ActiveRecord::Migration
  def change
    add_column :mappings, :revoked, :boolean, default: false
  end
end
