class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user
      t.references :commentable, :polymorphic => true
      t.text :content
      t.integer :hits
      t.integer :vote_up, :default=>0
      t.integer :vote_down, :default=>0
      t.datetime :activity_at
      t.integer :status, :limit => 1, :default => Comment::STATUS_ACTIVE
      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, :activity_at
    add_index :comments, [ :commentable_type, :commentable_id]
  end
end
