class UpdateUsersTable < ActiveRecord::Migration

  def self.up
    rename_column(:users, :first_name, :full_name)    
    remove_column :users, :last_name
  end

  def self.down
    rename_column(:users, :name, :first_name)
    add_column(:users, :last_name, :string)
  end
end
