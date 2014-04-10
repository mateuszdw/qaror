class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :user
      t.string :slug
      t.string :name
      t.integer :quantity, :default=>0
      t.integer :status, :limit => 1, :default => Tag::STATUS_ACTIVE
      t.timestamps
    end

    add_index :tags, :user_id
    add_index :tags, :created_at
  end
end
