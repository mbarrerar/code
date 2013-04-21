module SpaceOwnersHelper

  ##
  # Predicate that determines if the user has any permission for the
  # repository.
  #
  # @param [Repository]
  # @param [User]
  # @return [Boolean]
  #
  def admin?(space, user)
    Space.administrator?(space, user)
  end

  ##
  # @param [Repository]
  # @param [User]
  # @return [String, nil] "admin" or ""
  #
  def permission(space, user)
    admin?(space, user) ? "admin" : ""
  end

  def permissions()
    ["admin", ""]
  end

  ##
  # CSS string used to fade out a row for a user that is an admin
  # for a space.
  #
  # @param [Space]
  # @param [User]
  # @return [String]
  #
  def has_permission_css(space, user)
    if admin?(space, user)
      "class='has_permission'"
    end
  end

end
