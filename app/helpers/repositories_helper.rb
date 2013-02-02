module RepositoriesHelper

  def repository_title(repo)
    "Repository: #{repo.name()}"
  end

  # Returns the select options for the 'edit' action
  def spaces_for_new(user)
    options = user.spaces.
        all(:order => 'name').
        map { |space| [space.name, space.id] }
    options << ["Create in NEW Space", 0]
  end
  
  # Returns repo's current space to populate r/o select for "Old Space"
  def spaces_for_old_space(repo)
    space = repo.space
    [[space.name, space.id]]
  end
  
  # Returns the select option for repo's edit space.
  def spaces_for_new_space(user, repo)
    user.spaces.
        all(:order => 'name').
        reject { |space| space == repo.space }.
        map { |space| [space.name, space.id] }
  end

  def url_was(repository)
    name = App.svn_username()
    host = App.svn_connection_url()
    space = Space.find(repository.space_id_was).name()
    "svn+ssh://#{name}@#{host}/#{space}/#{repository.name_was()}"
  end

end
