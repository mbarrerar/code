class EnableHudsonField < ActiveRecord::Migration
  def self.up
    add_column :repositories, :uses_hudson_ci, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :repositories, :uses_hudson_ci
  end
end
