module Admin::SpaceTabsHelper

  def minor_tabs(space)
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_admin_space_path(space))
      ts.add(:repos, admin_space_repositories_path(space), :label => "Repositories")
      ts.add(:administrators, admin_space_administrators_path(space), :label => "Administrators")
      ts.add(:deploy_keys, admin_space_deploy_keys_path(space))
    end
  end

end
