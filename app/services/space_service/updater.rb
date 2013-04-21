module SpaceService
  class Updater
    include OwnershipChecker

    UpdateError = Class.new(StandardError)

    attr_accessor :current_user, :space

    def initialize(args={})
      args.symbolize_keys!
      @current_user = args.fetch(:current_user)
      @space = args.fetch(:space)
    end

    def update(space_params)
      check_ownership!
        #@space.update
    rescue OwnershipError => e
      raise(UpdateError, e.message)
    end

  end
end
