module SpacesHelper

  def space_link_to_edit(user, space)
    default_options = {:class => "mini_button_widget"}
    url = space.owned_by?(user) ? edit_space_url(space) : space_url(space)
    link_to("Edit", url, default_options)
  end

  def space_title(space)
    "Space: #{space.name}"
  end

  def permission_widget(user, space)
    if space.owned_by?(user)
      "admin"
    else
      select_tag(user.id, options_for_select(permissions(), permission(space, user)))
    end
  end

  def url_will_be(space, repo)
    name = App.svn_username()
    host = App.svn_connection_url()
    "svn+ssh://#{name}@#{host}/#{space.name()}/#{repo.name()}"
  end
end
