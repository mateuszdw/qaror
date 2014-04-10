class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.references :user
      t.references :badge
      t.references :tag
      t.references :activity
      t.integer :trigger_id
      t.datetime :created_at
    end

    add_index :achievements, :user_id
    add_index :achievements, :badge_id
    add_index :achievements, :tag_id
    add_index :achievements, :activity_id
    add_index :achievements, :trigger_id
  end
end
