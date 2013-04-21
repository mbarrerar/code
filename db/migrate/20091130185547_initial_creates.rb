class InitialCreates < ActiveRecord::Migration
  def self.up
    create_table "collaborations", :force => true do |t|
      t.integer "repository_id", :null => false
      t.integer "user_id", :null => false
      t.string "permission", :default => "read", :null => false
      t.timestamps
    end
    add_index "collaborations", ["repository_id"], :name => "index_collaborations_on_repo_id"
    add_index "collaborations", ["user_id"], :name => "index_collaborations_on_user_id"

    create_table "repositories", :force => true do |t|
      t.integer "space_id"
      t.string "name", :null => false
      t.integer "user_id", :null => false
      t.integer "actual_size", :limit => 8, :default => 0
      t.text "description"
      t.datetime "committed_at"
      t.boolean "uses_hudson_ci", :default => false, :null => false
      t.timestamps
    end
    add_index "repositories", ["space_id"], :name => "index_repository_on_space_id"

    create_table "sessions", :force => true do |t|
      t.string "session_id", :null => false
      t.text "data"
      t.timestamps
    end
    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "space_ownerships", :force => true do |t|
      t.integer "space_id"
      t.integer "user_id"
      t.timestamps
    end

    create_table "spaces", :force => true do |t|
      t.string "name", :null => false
      t.text "description"
      t.integer "actual_size", :limit => 8, :default => 0
      t.timestamps
    end

    create_table "ssh_keys", :force => true do |t|
      t.string "name", :null => false
      t.text "key", :null => false
      t.integer "user_id"
      t.integer "ssh_key_authenticatable_id"
      t.string "ssh_key_authenticatable_type"
      t.timestamps
    end
    add_index "ssh_keys", ["ssh_key_authenticatable_id"], :name => "index_ssh_keys_on_ssh_key_authenticatable_id"
    add_index "ssh_keys", ["user_id"], :name => "index_ssh_keys_on_user_id"

    create_table "users", :force => true do |t|
      t.integer "ldap_uid"
      t.string "username"
      t.string "name"
      t.string "email"
      t.boolean "admin", :default => false, :null => false
      t.boolean "active", :default => true, :null => false
      t.boolean "agreed_to_terms", :default => false, :null => false
      t.datetime "last_svn_access"
      t.datetime "last_login"
      t.text "bio"
      t.timestamps
    end
  end

  def self.down
  end
end
