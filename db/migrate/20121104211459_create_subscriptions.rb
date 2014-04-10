class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user
      t.references :subscribable, :polymorphic => true
      t.integer :auto, :default => 1
      t.datetime :last_view
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, [ :subscribable_type, :subscribable_id]
  end
end
