class SpaceAdministratorLookupService
  
  class << self
    ##
    # Predicate that determins if the user is an administrator of the space.
    #
    # @param [Space]
    # @param [User]    
    # @returns [Array<User>]
    #
    def administrator?(space, user)
      space.administrators.include?(user)
    end
  end

end
