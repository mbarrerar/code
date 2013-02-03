module Admin::UsersHelper

  def user_left_nav_tabs(user)
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_admin_user_url(user))
      ts.add(:ssh_keys, admin_user_ssh_keys_url(user), :label => "SSH Keys")
      ts.add(:permissions, admin_user_permissions_url(user))
    end
  end

  def user_title(user)
    "#{user.full_name} (#{user.username})"
  end

  def date_or_none(date, format=:mdy_hms)
    date.try(:to_s, format) || "none"
  end
end
