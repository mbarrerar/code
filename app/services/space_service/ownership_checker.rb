module SpaceService
  module OwnershipChecker
    OwnershipError = Class.new(StandardError)

    def check_ownership!
      unless space.owner?(current_user)
        raise(OwnershipError, "User is not Space Owner")
      end
    end

  end
end
