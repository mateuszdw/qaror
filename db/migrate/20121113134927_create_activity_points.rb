class CreateActivityPoints < ActiveRecord::Migration
  def change
    create_table :activity_points do |t|
      t.references :user
      t.references :activity
      t.integer :value
      t.datetime :created_at
      t.integer :undo, :limit => 1, :default => 0
    end

    add_index :activity_points, :user_id
    add_index :activity_points, :activity_id
  end

end
