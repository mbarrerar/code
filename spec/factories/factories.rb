
FactoryGirl.define do
  factory(:repository) do
    association(:space)
    sequence(:name) { |n| "name-#{n}" }
    description { |r| "description for #{r.name}" }
  end

  factory(:space) do
    sequence(:name) { |n| "name-#{n}" }
    description { |s| "description for #{s.name}" }
    association(:owner, :factory => :user)
  end

  factory(:space_administration) do
    association(:user)
    association(:space)
    association(:created_by, :factory => :user)
  end

  factory(:collaboration) do
    association(:user)
    association(:repository)
    association(:created_by, :factory => :user)
  end

  factory(:utility_user) do
    sequence(:username) { |n| "username-#{n}" }
  end

  factory(:ssh_key) do
    association(:ssh_key_authenticatable, :factory => :user)
    sequence(:name) { |n| "name-#{n}" }
    key { |k| "ssh_key for #{k.name} " }
  end

  factory(:hudson_ssh_key) do
    sequence(:name) { |n| "name-#{n}-#{n}" }
    key { |k| "hudson_ssh_key for #{k.name} " }
  end
end
