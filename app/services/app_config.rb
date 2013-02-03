class AppConfig
  VERSION = "1.10"

  @conf = YAML::load(ERB.new(IO.read("#{Rails.root}/config/config.yml")).result)[Rails.env].symbolize_keys!
  #@conf = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys!
  @conf[:version] = VERSION

  def self.[](key)
    @conf.fetch(key.to_sym)
  end

  def self.cas_url
    @conf.fetch(:cas_url)
  end

  def self.cas_logout
    @conf.fetch(:cas_logout)
  end

  def self.ldap_host
    @conf.fetch(:ldap_host)
  end

  def self.svn_root
    @conf.fetch(:svn_root)
  end

  def self.app_user
    @conf.fetch(:app_user)
  end

  def self.app_group
    @conf.fetch(:app_group)
  end

  def self.archive_dir
    @conf.fetch(:archive_dir)
  end

  def self.sandbox_dir
    @conf.fetch(:sandbox_dir)
  end
end
