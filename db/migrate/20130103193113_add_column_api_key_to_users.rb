class AddColumnApiKeyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :apikey, :string
  end

  def self.down
    remove_column :users, :apikey
  end
end
