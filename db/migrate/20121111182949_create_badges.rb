class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :name
      t.integer :achieved_count,:default => 0
      t.integer :badge_type
      t.timestamps
    end
  end
end
