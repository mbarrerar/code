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

ActiveRecord::Schema.define(:version => 20091130185547) do

  create_table "collaborations", :force => true do |t|
    t.integer  "repository_id",                     :null => false
    t.integer  "user_id",                           :null => false
    t.string   "permission",    :default => "read", :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "collaborations", ["repository_id"], :name => "index_collaborations_on_repo_id"
  add_index "collaborations", ["user_id"], :name => "index_collaborations_on_user_id"

  create_table "repositories", :force => true do |t|
    t.integer  "space_id"
    t.string   "name",                                           :null => false
    t.integer  "user_id",                                        :null => false
    t.integer  "actual_size",    :limit => 8, :default => 0
    t.text     "description"
    t.datetime "committed_at"
    t.boolean  "uses_hudson_ci",              :default => false, :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "repositories", ["space_id"], :name => "index_repository_on_space_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "space_ownerships", :force => true do |t|
    t.integer  "space_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "spaces", :force => true do |t|
    t.string   "name",                                    :null => false
    t.text     "description"
    t.integer  "actual_size", :limit => 8, :default => 0
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "ssh_keys", :force => true do |t|
    t.string   "name",                         :null => false
    t.text     "key",                          :null => false
    t.integer  "user_id"
    t.integer  "ssh_key_authenticatable_id"
    t.string   "ssh_key_authenticatable_type"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "ssh_keys", ["ssh_key_authenticatable_id"], :name => "index_ssh_keys_on_ssh_key_authenticatable_id"
  add_index "ssh_keys", ["user_id"], :name => "index_ssh_keys_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "ldap_uid"
    t.string   "username"
    t.string   "name"
    t.string   "email"
    t.boolean  "admin",           :default => false, :null => false
    t.boolean  "active",          :default => true,  :null => false
    t.boolean  "agreed_to_terms", :default => false, :null => false
    t.datetime "last_svn_access"
    t.datetime "last_login"
    t.text     "bio"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

end
