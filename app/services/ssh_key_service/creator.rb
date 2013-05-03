module SshKeyService
  class Creator
    CreateError = Class.new(StandardError)

    attr_accessor :current_user, :key_owner, :ssh_key, :key_writer, :audit_logger

    def initialize(args={})
      args.symbolize_keys!
      @key_owner = args.fetch(:key_owner)
      @current_user = args.fetch(:current_user)
      @key_writer = args.fetch(:key_writer, default_key_writer)
      @audit_logger = args.fetch(:audit_logger, default_audit_logger)
    end

    def create(params)
      save_key_to_db(params)
      update_authz_keys_file
      log_key_creation
    rescue ActiveRecord::RecordInvalid
      nil
    end

    private

    def default_key_writer
      AuthzKeysFile.new
    end

    def default_audit_logger
      SshKeyAudit
    end

    def save_key_to_db(params)
      @ssh_key = key_owner.ssh_keys.build(params)
      @ssh_key.save!
    end

    def update_authz_keys_file
      key_writer.write(SshKey.all)
    end

    def log_key_creation
      audit_logger.log(ssh_key, current_user, :create)
    end
  end
end
