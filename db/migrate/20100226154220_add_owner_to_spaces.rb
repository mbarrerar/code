class AddOwnerToSpaces < ActiveRecord::Migration
  def self.up
    add_column :spaces, :owner_id, :integer
  end

  def self.down
    remove_column :spaces, :owner_id
  end
end
