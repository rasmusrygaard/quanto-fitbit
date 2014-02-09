class AddProviderToMapping < ActiveRecord::Migration
  def change
    add_column :mappings, :provider, :string
  end
end
