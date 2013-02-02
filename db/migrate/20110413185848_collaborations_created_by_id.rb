class CollaborationsCreatedById < ActiveRecord::Migration
  def self.up
    add_column :collaborations, :created_by_id, :integer
  end

  def self.down
    remove_column :collaborations, :created_by_id
  end
end
