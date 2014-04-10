class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.references :user
      t.integer :notify_enabled, :default=> 0
      t.integer :notify_new_member_joins,:default=> 0
      t.integer :notify_new_question,:default=> 0
      t.integer :notify_new_question_with_my_tags,:default=> 0
      t.integer :notify_answers,:default=> 0
      t.integer :notify_answer_resolved,:default=> 0
      t.integer :notify_comments,:default=> 0
    end

    add_index :user_settings, :user_id
  end
end
