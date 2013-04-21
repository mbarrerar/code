class AddTAndCToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :agreed_to_terms, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :agreed_to_terms
  end
end
