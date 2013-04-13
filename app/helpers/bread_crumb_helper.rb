module BreadCrumbHelper

  def set_bread_crumbs(*crumbs)
    @bread_crumbs = crumbs
  end

  def bread_crumbs
    crumbs = (@bread_crumbs || []).unshift(link_to('Dashboard', dashboard_url))

    content_tag(:ul, :class => 'breadcrumb') do
      crumbs.map.with_index { |c, i|
        crumb_link = (c.class == Symbol ? self.send(c) : c).html_safe
        content_tag(:li) do
          if i == crumbs.length-1
            crumb_link
          else
            crumb_link + ' ' + content_tag(:span, '/', :class => 'divider')
          end
        end
      }.join.html_safe
    end
  end

  ###########################################################################
  # Space Bread Crumbs
  ###########################################################################
  def spaces_crumb
    link_to('Spaces', spaces_url)
  end

  def edit_space_crumb(space)
    link_to(space.name, edit_space_url(space))
  end

  def view_space_crumb(space)
    link_to(space.name, space_url(space))
  end

  def deploy_keys_crumb(space)
    link_to('Deploy Keys', space_deploy_keys_url(space))
  end

  def space_administrators_crumb(space)
    link_to('Administrators', space_space_administrations_url(space))
  end

  ###########################################################################
  # Repository Bread Crumbs
  ###########################################################################
  def repositories_crumb
    link_to('Repositories', repositories_url)
  end

  def edit_repository_crumb(repo)
    link_to(repo.name, edit_repository_url(repo))
  end

  def repository_collaborators_crumb(repo)
    link_to('Collaborators', repository_collaborations_url(repo))
  end

  ###########################################################################
  # Profile Bread Crumbs
  ###########################################################################
  def edit_profile_crumb
    link_to('Repositories', repositories_url)
  end

  ###########################################################################
  # SSH Public Keys Bread Crumbs
  ###########################################################################
  def ssh_keys_crumb
    link_to('SSH Keys', ssh_keys_url)
  end

  ###########################################################################
  # Repository Directory Bread Crumbs
  ###########################################################################
  def repository_directory_crumb
    link_to('Repository Directory', repository_directory_url)
  end

end
