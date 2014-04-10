class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user
      t.references :activityable, :polymorphic => true
      t.string :name
      t.string :ip
      t.datetime :created_at
      t.datetime :undo_at
      t.text :extra
    end
    add_column :activities, :undo, :integer, :limit => 1, :default => 0

    add_index :activities, [ :activityable_type, :activityable_id]
    add_index :activities, :user_id
    add_index :activities, :created_at
    add_index :activities, :name
  end
end