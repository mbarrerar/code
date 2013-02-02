module Admin::RepositoryTabsHelper

  def minor_tabs(repo)
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_admin_repository_path(repo))
      ts.add(:collaborators, admin_repository_collaborations_path(repo), :dom_id => dom_id(repo, "collaborations"))
    end
  end

end