# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140530201929) do

  create_table "achievements", :force => true do |t|
    t.integer  "user_id"
    t.integer  "badge_id"
    t.integer  "tag_id"
    t.integer  "activity_id"
    t.integer  "trigger_id"
    t.datetime "created_at"
  end

  add_index "achievements", ["activity_id"], :name => "index_achievements_on_activity_id"
  add_index "achievements", ["badge_id"], :name => "index_achievements_on_badge_id"
  add_index "achievements", ["tag_id"], :name => "index_achievements_on_tag_id"
  add_index "achievements", ["trigger_id"], :name => "index_achievements_on_trigger_id"
  add_index "achievements", ["user_id"], :name => "index_achievements_on_user_id"

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activityable_id"
    t.string   "activityable_type"
    t.string   "name"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "undo_at"
    t.text     "extra"
    t.integer  "undo",              :limit => 2, :default => 0
  end

  add_index "activities", ["activityable_type", "activityable_id"], :name => "index_activities_on_activityable_type_and_activityable_id"
  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["name"], :name => "index_activities_on_name"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "activity_points", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.integer  "value"
    t.datetime "created_at"
    t.integer  "undo",        :limit => 2, :default => 0
  end

  add_index "activity_points", ["activity_id"], :name => "index_activity_points_on_activity_id"
  add_index "activity_points", ["user_id"], :name => "index_activity_points_on_user_id"

  create_table "ans", :force => true do |t|
    t.integer  "thr_id"
    t.integer  "user_id"
    t.text     "content"
    t.integer  "hits",                     :default => 0
    t.integer  "vote_up",                  :default => 0
    t.integer  "vote_down",                :default => 0
    t.datetime "activity_at"
    t.integer  "status",      :limit => 2, :default => 1
    t.integer  "resolved",    :limit => 2
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "ans", ["thr_id"], :name => "index_ans_on_thr_id"
  add_index "ans", ["user_id"], :name => "index_ans_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "badges", :force => true do |t|
    t.string   "name"
    t.integer  "achieved_count", :default => 0
    t.integer  "badge_type"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "content"
    t.integer  "hits"
    t.integer  "vote_up",                       :default => 0
    t.integer  "vote_down",                     :default => 0
    t.datetime "activity_at"
    t.integer  "status",           :limit => 2, :default => 1
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "comments", ["activity_at"], :name => "index_comments_on_activity_at"
  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "impressions", :force => true do |t|
    t.integer  "impressionable_id"
    t.string   "impressionable_type"
    t.integer  "user_id"
    t.string   "ip"
    t.datetime "created_at"
  end

  add_index "impressions", ["impressionable_type", "impressionable_id"], :name => "index_impressions_on_impressionable_type_and_impressionable_id"
  add_index "impressions", ["ip"], :name => "index_impressions_on_ip"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subscribable_id"
    t.string   "subscribable_type"
    t.integer  "auto",              :default => 1
    t.datetime "last_view"
  end

  add_index "subscriptions", ["subscribable_type", "subscribable_id"], :name => "index_subscriptions_on_subscribable_type_and_subscribable_id"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "tag_rels", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "tag_rels", ["tag_id"], :name => "index_tag_rels_on_tag_id"
  add_index "tag_rels", ["taggable_type", "taggable_id"], :name => "index_tag_rels_on_taggable_type_and_taggable_id"

  create_table "tags", :force => true do |t|
    t.integer  "user_id"
    t.string   "slug"
    t.string   "name"
    t.integer  "quantity",                :default => 0
    t.integer  "status",     :limit => 2, :default => 1
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "tags", ["created_at"], :name => "index_tags_on_created_at"
  add_index "tags", ["user_id"], :name => "index_tags_on_user_id"

  create_table "thrs", :force => true do |t|
    t.integer  "user_id"
    t.string   "slug"
    t.string   "title"
    t.text     "content"
    t.integer  "hits",                               :default => 0
    t.integer  "vote_up",                            :default => 0
    t.integer  "vote_down",                          :default => 0
    t.integer  "last_activity_id"
    t.integer  "last_activity_user_id"
    t.datetime "activity_at"
    t.string   "tagnames"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "status",                :limit => 2, :default => 1
    t.integer  "hotness",                            :default => 0
  end

  add_index "thrs", ["activity_at"], :name => "index_thrs_on_activity_at"
  add_index "thrs", ["created_at"], :name => "index_thrs_on_created_at"
  add_index "thrs", ["slug"], :name => "index_thrs_on_slug"
  add_index "thrs", ["user_id"], :name => "index_thrs_on_user_id"

  create_table "user_settings", :force => true do |t|
    t.integer "user_id"
    t.integer "notify_enabled",                   :default => 0
    t.integer "notify_new_member_joins",          :default => 0
    t.integer "notify_new_question",              :default => 0
    t.integer "notify_new_question_with_my_tags", :default => 0
    t.integer "notify_answers",                   :default => 0
    t.integer "notify_answer_resolved",           :default => 0
    t.integer "notify_comments",                  :default => 0
  end

  add_index "user_settings", ["user_id"], :name => "index_user_settings_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.string   "password_salt"
    t.string   "email"
    t.string   "www"
    t.string   "about"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "last_login"
    t.datetime "birth"
    t.string   "timezone"
    t.string   "language"
    t.string   "remind_token"
    t.string   "activation_hash"
    t.string   "ranks"
    t.integer  "reputation",                   :default => 0
    t.integer  "status",          :limit => 2, :default => 0
    t.integer  "role",            :limit => 2, :default => 0
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "apikey"
    t.string   "avatar_url"
  end

  add_index "users", ["avatar_url"], :name => "index_users_on_avatar_url"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.string   "summary"
    t.integer  "user_id"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["user_id"], :name => "index_versions_on_user_id"

end
