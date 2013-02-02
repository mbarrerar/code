class LdapPersonFinderService
  PersonNotFound = Class.new(StandardError)

  def find_by_uid(uid)
    find_by_attributes(:uid => uid.to_s).first
  end

  def find_by_uid!(uid)
    find_by_uid(uid) or raise(PersonNotFound, "uid=#{uid.inspect}")
  end

  def find_by_first_last(first_name, last_name)
    find_by_attributes(:givenname => first_name, :sn => last_name)
  end

  def find_by_attributes(attributes)
    attributes.each { |k, v| attributes.delete(k) if v.blank?  }
    UCB::LDAP::Person.
        search(:filter => build_filter(attributes)).
        map { |ldap_entry| new_ldap_person_entry(ldap_entry) }
  end

  def new_ldap_person_entry(ldap_entry)
    LdapPersonEntry.new(
        :ldap_uid => ldap_entry.uid,
        :first_name => ldap_entry.givenname.first,
        :last_name => ldap_entry.sn.first,
        :email => ldap_entry.mail.first,
        :affiliations => ldap_entry.berkeleyeduaffiliations
    )
  end

  def build_filter(attrs)
    filter_parts = attrs.map { |k, v| build_filter_part(k, v) }
    filter = filter_parts.inject { |accum, filter| accum.send(:&, filter) }
    filter
  end

  def build_filter_part(key, value)
    value = key.to_s == 'uid' ? value : "#{value}*"
    Net::LDAP::Filter.eq(key.to_s, value)
  end


  def self.klass
    if Rails.env.test?
      LdapTestPersonFinderService
    else
      self
    end
  end

  def self.method_missing(method, *args)
    klass.new.send(method, *args)
  end

end
