module Admin::UsersHelper

  def user_left_nav_tabs()
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_admin_user_url(@user))
      ts.add(:ssh_keys, admin_user_ssh_keys_url(@user), :label => "SSH Keys")
      ts.add(:repository_permissions, admin_user_collaborations_url(@user))
    end
  end

  def user_title(user)
    "#{user.full_name} (#{user.username})"
  end

end
