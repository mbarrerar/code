class AddCommittedAt < ActiveRecord::Migration
  def self.up
    add_column :repositories, :committed_at, :timestamp
  end

  def self.down
    remove_column :repositories, :committed_at
  end
end
