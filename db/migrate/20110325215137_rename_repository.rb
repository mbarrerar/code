class RenameRepository < ActiveRecord::Migration
  def self.up
    rename_table(:repos, :repositories)
    rename_column(:collaborations, :repo_id, :repository_id)
    remove_column(:users, :department)
  end

  def self.down
    rename_table(:repositories, :repos)
    rename_column(:collaborations, :repository_id, :repo_id)
    add_column(:users, :department)
  end
end
