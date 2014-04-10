class CreateTagRels < ActiveRecord::Migration
  def change
    create_table :tag_rels do |t|
      t.references :tag
      t.references :taggable, :polymorphic => true
      t.datetime :created_at
    end

    add_index :tag_rels, :tag_id
    add_index :tag_rels, [ :taggable_type, :taggable_id]

  end
end
