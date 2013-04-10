

def user_form_id(user)
  user.new_record? ? "form#new_user" : "form#edit_#{dom_id(user)}"
end

def verify_user_row(user)
  [:full_name, :ldap_uid, :department, :email].each do |att|
    assert_have_selector("table#admin_user_list tr##{dom_id(user)} td", :content => user.send(att).to_s)      
  end
end

def verify_user_has_no_row(user)
  assert_have_no_selector("#admin_user_list tr##{dom_id(user)} td")
end

def verify_user_form(user)
  assert_have_selector(user_form_id(user))
  
  [:full_name, :ldap_uid, :email, :department].each do |att|
    assert_have_selector("#{user_form_id(user)} input[id=user_#{att}][value='#{user.send(att).to_s}']")
  end
end
