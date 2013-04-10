def login_user(obj)
  ldap_uid = obj.is_a?(User) ? obj.ldap_uid : obj
  visit(root_path(:test_auth_ldap_uid => ldap_uid))
end

def logger
  Rails.logger
end

def dom_id(*args)
  App.dom_id(*args)
end

def row_sel(model, options = {})
  id = options.delete(:id)
  prefix = options.delete(:prefix)

  id = model.class.name.underscore unless id
  id = prefix.concat("_#{id}") if prefix

  "table##{id}_list tr##{dom_id(model)}"
end

def edit_form_sel(model)
  "form##{dom_id(model, 'edit')}"
end

def error_count_msg(obj)
  return "" if obj.errors.length == 0
  msg = "prohibited this #{obj.class.name.downcase} from being saved"
  (obj.errors.length == 1) ? "error ".concat(msg) : "errors ".concat(msg)
end

def assert_admin_site
  assert_have_selector("h1 > span", :content => "Code@Berkeley Admin")
end


###############################################################################
# List of test ids:
# https://wikihub.berkeley.edu/display/calnet/Universal+Test+IDs
###############################################################################


def create_admin_user
  admin = FactoryGirl.create(:user, {
    :ldap_uid => 232588,
    :full_name => "admin",
    :email => "admin@berkeley.edu",
    :username => "test-232588",
    :admin => true,
    :active => true,
    :terms_and_conditions => true
  })
  key = "ssh_key-#{admin.id}"
  admin.ssh_keys.create(:name => key, :key => key)
  admin
end

def create_staff_user
  staff = FactoryGirl.create(:user, {
    :ldap_uid => 212387,
    :full_name => "staff",
    :email => "staff@berkeley.edu",
    :username => "test-212387",
    :admin => false,
    :active => true,
    :terms_and_conditions => true
  })
  key = "ssh_key-#{staff.id}"
  staff.ssh_keys.create(:name => key, :key => key)
  staff
end

def create_faculty_user
  faculty = FactoryGirl.create(:user, {
    :ldap_uid => 212386,
    :full_name => "faculty",
    :email => "faculty@berkeley.edu",
    :username => "test-212386",
    :admin => false,
    :active => true,
    :terms_and_conditions => true
  })
  key = "ssh_key-#{faculty.id}"
  faculty.ssh_keys.create(:name => key, :key => key)
  faculty
end

def create_student_user
  student = FactoryGirl.create(:user, {
    :ldap_uid => 212381,
    :full_name => "student",
    :email => "student@berkeley.edu",
    :username => "test-212381",
    :admin => false,
    :active => true,
    :terms_and_conditions => true
  })
  key = "ssh_key-#{student.id}"
  student.ssh_keys.create(:name => key, :key => key)
  student
end

