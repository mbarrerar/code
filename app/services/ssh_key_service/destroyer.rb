module SshKeyService
  class Destroyer
    DeleteError = Class.new(StandardError)

    attr_accessor :current_user, :key_owner, :ssh_key, :key_writer, :audit_logger

    def initialize(args={})
      args.symbolize_keys!
      @key_owner = args.fetch(:key_owner)
      @current_user = args.fetch(:current_user)
      @key_writer = args.fetch(:key_writer, default_key_writer)
      @audit_logger = args.fetch(:audit_logger, default_audit_logger)
    end

    def destroy(key_id)
      remove_key_from_db(key_id)
      update_authz_keys_file
      log_key_deletion
    end

    private

    def default_key_writer
      AuthzKeyFileWriter.new
    end

    def default_audit_logger
      SshKeyAudit
    end

    def remove_key_from_db(key_id)
      @ssh_key = key_owner.ssh_keys.find(key_id)
      @ssh_key.destroy
    end

    def update_authz_keys_file
      key_writer.write(SshKey.all)
    end

    def log_key_deletion
      audit_logger.log(ssh_key, current_user, :destroy)
    end
  end
end
