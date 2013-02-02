class App
  VERSION = "rel-0.0.5"

  # Template proxy providing access to helper methods
  cattr_accessor :template
  self.template = ActionView::Base.new

  # validation regexp for space, repo name
  ENTITY_NAME_REGEXP = /^[\w\-]+$/

  # error message for failed entity name validation
  ENTITY_NAME_REGEXP_ERROR_MESSAGE = 'can only contain letters, numbers, "_" and "-"'


  def self.call_os_cmd(cmd)
    Rails.logger.debug("Running OS cmd: #{cmd}")
    result = `#{cmd} 2>&1`
    rc = $?.exitstatus
    Rails.logger.debug("RC: #{rc.inspect}")
    Rails.logger.debug("Result: #{result.inspect}")
    [rc, result]
  end

  def self.svn_connection_url
    if Rails.env.production?
      "code.berkeley.edu"
    elsif Rails.env.quality_assurance?
      "code-qa.berkeley.edu"
    else
      "localhost"
    end
  end

  def self.test_email
    "runner@berkeley.edu"
  end

  def self.svn_username
    "svn"
  end

  def self.dom_id(*args)
    template.dom_id(*args)
  end

  def self.number_to_human_size(*args)
    template.number_to_human_size(*args)
  end

  def self.msg_not_authorized
    "Not Authorized"
  end

  def self.label(model_name, attr_name)
    I18n.t(:"simple_form.labels.#{model_name}.#{attr_name}")
  end

  def self.view_msg(key)
    I18n.t(:"simple_form.view_messages.#{key}")
  end

  def self.msg(string_path)
    I18n.t(:"simple_form.messages.#{string_path}")
  end

  def self.error(string_path)
    I18n.t(:"simple_form.errors.#{string_path}")
  end
end
