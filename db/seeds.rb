# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(:name => "Steven Hansen", :ldap_uid => 61065, :username => "runner", :admin => true, :active => true, :agreed_to_terms => true, :email => 'runner@berkeley.edu')
User.create(:name => "Elle Yoko Suzuki", :ldap_uid => 58431, :username => "elle.suzuki", :admin => false, :active => true, :agreed_to_terms => true, :email => 'elle.suzuki@berkeley.edu')
User.create(:name => "Yu-Tin Kuo", :ldap_uid => 19154, :username => "yutin", :admin => false, :active => true, :agreed_to_terms => true, :email => 'yutin@berkeley.edu')
User.create(:name => "Steve Downey", :ldap_uid => 191501, :username => "sldowney", :admin => false, :active => true, :agreed_to_terms => true, :email => 'steve.downtown@gmail.com')
