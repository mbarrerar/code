class SpaceLookupService

  ##
  # @params [User]
  # @return [Array<Space>]
  #
  def self.find_owned_by(user)
    user.spaces_owned
  end

end
