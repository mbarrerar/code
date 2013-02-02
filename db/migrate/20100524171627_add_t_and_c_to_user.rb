class AddTAndCToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :terms_and_conditions, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :terms_and_conditions
  end
end
