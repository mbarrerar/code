class LdapPersonSearcherService
  ALIAS_MAP = {
      :ldap_uid => :uid,
      :first_name => :givenname,
      :last_name => :sn,
      :email => :mail,
      :departments => :berkeleyeduunithrdeptname,
      :affiliations => :berkeleyeduaffiliations
  }

  class LdapEntry
    attr_accessor *ALIAS_MAP.keys
    attr_accessor :full_name

    def initialize(entry)
      ALIAS_MAP.each do |k,v|
        if entry.respond_to?(v)
          self.send("#{k}=", entry.send(v)[0].to_s)
        else
          self.send("#{k}=", nil)
        end
      end
      self.full_name = "#{first_name()} #{last_name()}"
    end
  end


  def initialize(host = AppConfig['ldap_host'])
    @host = host
    @ldap = Net::LDAP.new(:host => @host)
    raise Exception unless @ldap.bind()
  end

  def host
    @host.dump
  end

  def find(*attributes)
    attrs = extract_options!(attributes)
    return attrs if attrs.empty?

    results = @ldap.search(:base => "ou=people,dc=berkeley,dc=edu", :filter => build_filter(attrs))
    (results || []).map { |entry| LdapEntry.new(entry) }
  end

  def find_by_uid(uid)
    find(:ldap_uid => uid.to_s).first()
  end

  def build_filter(attrs)
    # sort to get repeatable order for unit tests
    filters = attrs.sort_by { |elem| "#{elem[0].to_s}" }.map do |elem|
      Net::LDAP::Filter.eq(*parse_element(elem))
    end
    filters.inject { |accum, filter| accum.send(:&, filter) }
  end


  private

  def parse_element(elem)
    attr = (ALIAS_MAP[elem[0].to_sym] || elem[0]).to_s
    val = (attr == "uid") ? elem[1] : "#{elem[1]}*"
    [attr.to_s, val]
  end

  def extract_options!(attributes)
    return attributes if attributes.empty?
    attributes.first.entries.select { |e| !e[1].blank? }
  end
end