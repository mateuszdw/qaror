class CreateAttaches < ActiveRecord::Migration
  def change
    create_table :attaches do |t|
      t.references :attachable, :polymorphic => true
      t.references :user
      t.string :remote_ip
      t.string :token
      t.string :attach_file_name
      t.string :attach_content_type
      t.integer :attach_file_size
      t.integer :status,:limit => 1, :default => Attach::STATUS_NOTASSIGN
      t.datetime :attach_updated_at
      t.timestamps
    end

    add_index :attaches, [:attachable_type, :attachable_id]
    add_index :attaches, :user_id
    add_index :attaches, :token
  end
end
