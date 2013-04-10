class HudsonSshKey < SshKey
  after_initialize :init_authenticable_type

  def init_authenticable_type
    self.ssh_key_authenticatable_type = self.class.name
    self.ssh_key_authenticatable_id = self.class.hudson_id
  end

  def username
    self.class.username
  end

  def self.all
    self.where(:ssh_key_authenticatable_type => self.name,
               :ssh_key_authenticatable_id => self.hudson_id)
  end

  def self.username
    'app_hudson'
  end

  def self.hudson_id
    1
  end

  def self.find_hudson_key(id)
    where(:id => id,
          :ssh_key_authenticatable_type => self.name,
          :ssh_key_authenticatable_id => self.hudson_id).first
  end
end
