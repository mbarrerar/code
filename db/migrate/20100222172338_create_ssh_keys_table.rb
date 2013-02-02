class CreateSshKeysTable < ActiveRecord::Migration
  def self.up
    create_table :ssh_keys do |t|
      t.string :name, :null => false            
      t.text :key, :null => false      
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ssh_keys
  end
end
