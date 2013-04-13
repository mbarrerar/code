module SpaceTabsHelper

  def minor_tabs(space)
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      edit_url = space.owned_by?(current_user) ? edit_space_url(space) : space_url(space)

      ts.add(:detail, edit_url)
      ts.add(:repositories, space_repositories_path(space), :label => 'Repositories')
      ts.add(:administrators, space_administrators_path(space), :label => 'Administrators')
      ts.add(:deploy_keys, space_deploy_keys_path(space))
    end
  end

end
