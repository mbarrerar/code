class SpaceLookupService

  class << self
    ##
    # @params [User]
    # @return [Array<Space>]
    #
    def find_administered_by(user)
      (user.spaces_administered() - find_owned_by(user)).sort_by { |n| n.name.downcase }.uniq
    end

    ##
    # @params [User]
    # @return [Array<Space>]
    #
    def find_owned_by(user)
      user.spaces_owned()
    end

    ##
    # @params [User]
    # @return [Array<Space>]
    #
    def find_owned_or_administered_by(user)
      (find_administered_by(user) + find_owned_by(user)).sort_by { |n| n.name.downcase }.uniq
    end

    ##
    # @param [User]
    # @param [String]  "administer", "own" or nil
    #
    def find_by_viewing(user, viewing)
      if viewing == "administer"
        find_administered_by(user)
      elsif viewing == "own"
        find_owned_by(user)
      else
        find_owned_or_administered_by(user)
      end
    end
  end

end
