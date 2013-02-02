class RepositoryUrlChangedMessage

  VALID_ATTRIBUTES = [:url_was, :message, :updated_by, :repository]
  attr_accessor(*VALID_ATTRIBUTES)

  def initialize(attrs = {})
    attrs.keys.each do |attr|
      self.send("#{attr}=", attrs[attr]) if VALID_ATTRIBUTES.include?(attr.to_sym)
    end
  end

  def collaborator_emails()
    return [] unless repository
    repository.collaborators(true).map(&:email) + repository.administrators.map(&:email)
  end


  ##
  # @param [User]
  # @param [Hash]
  # @return [Array<RepositoryUrlChangedMessage>]
  #
  def self.new_from_space_params(updated_by, params = {})
    space = find_space(params[:id])

    space.repositories.map do |repo|
      self.new.tap do |msg|
        msg.message = params[:message]
        msg.url_was = params[:url_was][repo.id.to_s]
        msg.updated_by = updated_by
        msg.repository = repo
      end
    end
  end

  ##
  # @param [User]
  # @param [Hash]
  # @return [RepositoryUrlChangedMessage]
  #
  def self.new_from_repository_params(updated_by, params = {})
    repo = Repository.find(params[:id])

    self.new.tap do |msg|
      msg.message = params[:message]
      msg.url_was = params[:url_was]
      msg.updated_by = updated_by
      msg.repository = repo
    end
  end

  def self.find_space(id)
    Space.find(id)
  end
end
