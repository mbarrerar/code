module SpaceService
  class Creator
    CreateError = Class.new(StandardError)

    attr_accessor :current_user, :space

    def initialize(args={})
      args.symbolize_keys!
      @current_user = args.fetch(:current_user)
    end

    def create(params)
      @space = Space.new(params)
      @space.owners.push(current_user)
      @space.save
      @space
    end

  end
end
