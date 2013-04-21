class UpdateDbSchema < ActiveRecord::Migration
  def up
    create_table(:space_ownerships) do |t|
      t.integer(:space_id)
      t.integer(:user_id)
      t.timestamps
    end

    add_column(:repositories, :user_id, :integer, :null => false)
    remove_column(:spaces, :owner_id)
  end

  def down
  end
end
