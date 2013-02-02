module Admin::BaseHelper

  def major_tabs
    TabNav::TabSet.new(self, :name => :major) do |ts|
      ts.add(:repositories, admin_repositories_url)
      ts.add(:spaces, admin_spaces_url)
      ts.add(:users, admin_users_url)
    end
  end
  
end
