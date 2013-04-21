module SpaceService
  class OwnerUpdater
    include OwnershipChecker

    OwnerUpdateError = Class.new(StandardError)

    attr_accessor :current_user, :space

    def initialize(args={})
      args.symbolize_keys!
      @current_user = args.fetch(:current_user)
      @space = args.fetch(:space)
    end

    def update(owner_ids)
      check_ownership!
      update_owners(owner_ids)
    rescue OwnershipError => e
      raise(OwnerUpdateError, e.message)
    end

    private

    def update_owners(owner_ids)
      owner_ids ||= {}
      owner_ids.delete(current_user.id.to_s)

      ActiveRecord::Base.transaction do
        space.owners.clear
        space.owners.push(current_user)
        new_owners = User.where("id IN(?)", owner_ids.keys)
        new_owners.each { |user| space.owners.push(user) }
      end
    end
  end
end
