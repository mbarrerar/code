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

ActiveRecord::Schema.define(:version => 20110717231223) do

  create_table "collaborations", :force => true do |t|
    t.integer  "repository_id",                     :null => false
    t.integer  "user_id",                           :null => false
    t.string   "permission",    :default => "read", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
  end

  add_index "collaborations", ["created_by_id"], :name => "index_collaborations_on_created_by_id"
  add_index "collaborations", ["repository_id"], :name => "index_collaborations_on_repo_id"
  add_index "collaborations", ["user_id"], :name => "index_collaborations_on_user_id"

  create_table "repositories", :force => true do |t|
    t.integer  "space_id"
    t.string   "name",                                     :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "actual_size",  :limit => 8, :default => 0
    t.datetime "committed_at"
  end

  add_index "repositories", ["space_id"], :name => "index_repos_on_space_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "space_administrations", :force => true do |t|
    t.integer  "space_id",      :null => false
    t.integer  "user_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
  end

  add_index "space_administrations", ["created_by_id"], :name => "index_space_administrations_on_created_by_id"
  add_index "space_administrations", ["space_id"], :name => "index_space_administrations_on_space_id"
  add_index "space_administrations", ["user_id"], :name => "index_space_administrations_on_user_id"

  create_table "spaces", :force => true do |t|
    t.string   "name",                                    :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "actual_size", :limit => 8, :default => 0
  end

  add_index "spaces", ["owner_id"], :name => "index_spaces_on_owner_id"

  create_table "ssh_keys", :force => true do |t|
    t.string   "name",                         :null => false
    t.text     "key",                          :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ssh_key_authenticatable_id"
    t.string   "ssh_key_authenticatable_type"
  end

  add_index "ssh_keys", ["ssh_key_authenticatable_id"], :name => "index_ssh_keys_on_ssh_key_authenticatable_id"
  add_index "ssh_keys", ["user_id"], :name => "index_ssh_keys_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "ldap_uid"
    t.string   "username"
    t.string   "full_name"
    t.string   "email"
    t.boolean  "admin",                :default => false, :null => false
    t.boolean  "active",               :default => true,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "terms_and_conditions", :default => false, :null => false
    t.datetime "last_svn_access"
    t.datetime "last_login"
  end

end
