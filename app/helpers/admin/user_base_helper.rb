module Admin::UserBaseHelper

  def user_left_nav_tabs()
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_admin_user_url(@user))
      ts.add(:ssh_keys, admin_user_ssh_keys_url(@user), :label => "SSH Keys")
      ts.add(:repository_permissions, admin_user_collaborations_url(@user))
    end
  end  

  def user_title(user)
    "User: #{user.full_name} <span>(#{user.username})</span>"
  end
end
