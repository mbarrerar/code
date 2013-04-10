module VisitorHelper
  def visit_home
    visit(root_url)
  end

  def visit_admin_home
    visit(admin_root_url)
  end

  def visit_admin_users
    visit(admin_users_url)
    click_link("Users")
  end

  def visit_admin_spaces
    visit(admin_spaces_url)
  end
end

