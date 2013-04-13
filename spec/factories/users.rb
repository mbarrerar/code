###############################################################################
# List of test ids:
# https://wikihub.berkeley.edu/display/calnet/Universal+Test+IDs
###############################################################################

FactoryGirl.define do

  factory(:user) do
    full_name 'full_name'
    sequence(:ldap_uid) { |n| n }
    sequence(:username) { |n| "username-#{n}" }
    sequence(:email) { |n| "email-#{n}@email.com" }
    admin false
    active true
    terms_and_conditions true

    trait(:admin) do
      full_name 'admin'
      ldap_uid 232588
      username 'test-232588'
      email 'admin@berkeley.edu'
      admin true
    end

    trait(:staff) do
      full_name 'staff'
      ldap_uid 212387
      username 'test-212387'
      email 'staff@berkeley.edu'
    end

    trait(:faculty) do
      full_name 'faculty'
      ldap_uid 212386
      username 'test-212386'
      email 'faculty@berkeley.edu'
    end

    trait(:student) do
      full_name 'student'
      ldap_uid 212381
      username 'test-212381'
      email 'student@berkeley.edu'
    end
  end
end

#  key = "ssh_key-#{admin.id}"
#  admin.ssh_keys.create(:name => key, :key => key)
#  admin
