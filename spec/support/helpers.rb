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
