class SpaceAdministrationCreatedBy < ActiveRecord::Migration
  def self.up
    add_column :space_administrations, :created_by_id, :integer
  end

  def self.down
    remove_column :space_administrations, :created_by_id
  end
end
