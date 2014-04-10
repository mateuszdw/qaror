class CreateAns < ActiveRecord::Migration
  def change
    create_table :ans do |t|
      t.references :thr
      t.references :user
      t.text :content
      t.integer :hits, :default=>0
      t.integer :vote_up, :default=>0
      t.integer :vote_down, :default=>0
      t.datetime :activity_at
      t.integer :status, :limit => 1,:default=>An::STATUS_ACTIVE
      t.integer :resolved, :limit => 1
      t.timestamps
    end

    add_index :ans, :thr_id
    add_index :ans, :user_id
  end
end
