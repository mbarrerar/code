module SpaceTabsHelper

  def minor_tabs(space)
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_space_url(space))
      ts.add(:repositories, space_repositories_path(space), :label => 'Repositories')
      ts.add(:owners, space_owners_path(space), :label => 'Owners')
      # ts.add(:owners, space_owners_path(space), :label => 'Owners')
      # ts.add(:administrators, space_administrators_path(space), :label => 'Administrators')
      ts.add(:deploy_keys, space_deploy_keys_path(space))
    end
  end

end
