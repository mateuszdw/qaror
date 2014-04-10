class CreateImpressions < ActiveRecord::Migration
  def self.up
    create_table :impressions do |t|
      t.references :impressionable, :polymorphic => true
      t.references :user
      t.string :ip
      t.datetime :created_at
    end

    add_index :impressions, :ip
    add_index :impressions, :user_id
    add_index :impressions, [ :impressionable_type, :impressionable_id]
  end

  def self.down
    drop_table :impressions
  end
end
