class SshKeyAudit
  ##
  # @param [SshKey]
  # @param [User]
  # @param [Sting] one of :update, :create or :destroy
  #
  def self.log(key, edited_by, action)
    audit = audit_msg(key.key, edited_by.full_name, key.user.full_name, action)
    Rails.logger.info(audit)
  end

  ##
  # @param [String]
  # @param [String]
  # @param [String]
  # @param [String]
  #
  def self.audit_msg(key_contents, edited_by, key_owner, action)
    "SSH_KEY_AUDIT [edited_by: #{edited_by}, key_owner: #{key_owner}, action: #{action}, key: #{key_contents}]"
  end
end
