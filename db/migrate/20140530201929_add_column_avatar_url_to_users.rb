class AddColumnAvatarUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_url, :string
    add_index :users, :avatar_url
  end
end
