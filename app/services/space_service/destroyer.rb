module SpaceService
  class Destroyer
    include OwnershipChecker

    DestroyError = Class.new(StandardError)

    attr_accessor :current_user, :space

    def initialize(args={})
      args.symbolize_keys!
      @current_user = args.fetch(:current_user)
      @space = args.fetch(:space)
    end

    def destroy
      check_ownership!
      @space.destroy
    rescue OwnershipError => e
      raise(DestroyError, e.message)
    end

  end
end
