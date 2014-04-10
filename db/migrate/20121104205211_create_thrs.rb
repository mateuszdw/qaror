class CreateThrs < ActiveRecord::Migration
  def change
    create_table :thrs do |t|
      t.references :user
      t.string :slug
      t.string :title
      t.text :content
      t.integer :hits, :default=>0
      t.integer :vote_up, :default=>0
      t.integer :vote_down, :default=>0
      t.integer :last_activity_id
      t.integer :last_activity_user_id
      t.datetime :activity_at
      t.string :tagnames
      t.timestamps
    end
    add_column :thrs, :status, :integer, :limit => 1, :default=> Thr::STATUS_ACTIVE
    add_column :thrs, :hotness, :integer, :default=>0
    
    add_index :thrs, :slug
    add_index :thrs, :user_id
    add_index :thrs, :activity_at
    add_index :thrs, :created_at
  end
end
