module RepositoryTabsHelper

  def minor_tabs(repo)
    TabNav::TabSet.new(self, :name => :minor) do |ts|
      ts.add(:detail, edit_repository_path(repo))
      ts.add(:collaborators, repository_collaborators_path(repo), :dom_id => dom_id(repo, 'collaborations'))
    end
  end

end
