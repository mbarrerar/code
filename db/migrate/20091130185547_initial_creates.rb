class InitialCreates < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.integer :ldap_uid
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :department
      t.boolean :admin, :null => false, :default => false
      t.boolean :active, :null => false, :default => true
      t.timestamps
    end
    
    create_table :spaces, :force => true do |t|
      t.string :name, :null => false
      t.text :description
      # what are we tracking on size?
      # t.integer :maximum_size, :null => false, :default => 0
      # t.integer :actual_size, :null => false, :default => 0
      t.timestamps
    end
    
    create_table :space_administrations, :force => true do |t|
      t.belongs_to :space, :null => false
      t.belongs_to :user, :null => false
      t.timestamps
    end
    
    create_table :repos, :force => true do |t|
      t.belongs_to :space
      t.string :name, :null => false
      t.text :description
      # any size columns?
      t.timestamps
    end
    
    create_table :collaborations, :force => true do |t|
      t.belongs_to :repo, :null => false
      t.belongs_to :user, :null => false
      t.string :permission, :null => false, :default => 'read'
      t.timestamps
    end
  end

  def self.down
    drop_table :collaborations
    drop_table :space_administrations
    drop_table :repos
    drop_table :spaces
    drop_table :users
  end
end
