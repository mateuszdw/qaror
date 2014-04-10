class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.string :password_salt
      t.string :email
      t.string :www
      t.string :about
      t.string :first_name
      t.string :last_name
      t.datetime :last_login
      t.datetime :birth
      t.string :timezone
      t.string :language
      t.string :remind_token
      t.string :activation_hash
      t.string :ranks
      t.integer :reputation, :default => 0
      t.integer :status, :limit=>1, :default => User::STATUS_ANONYMOUS
      t.integer :role, :limit=>1, :default => User::ROLE_NONE
      t.timestamps
    end

    add_index :users,:created_at
  end
end
