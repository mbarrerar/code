class LdapTestPersonFinderService
  PersonNotFound = Class.new(StandardError)

  def find_by_uid(uid)
    find_by_attributes(:ldap_uid => uid.to_s).first
  end

  def find_by_uid!(uid)
    find_by_uid(uid) || raise(PersonNotFound, "uid=#{uid.inspect}")
  end

  def find_by_first_last(first_name, last_name)
    find_by_attributes(:first_name => first_name, :last_name => last_name)
  end

  def find_by_attributes(attributes)
    self.class.entries.select { |entry| entry_matches_attributes(entry, attributes) }
  end

  def entry_matches_attributes(entry, attributes)
    attributes.keys.all? do |key|
      value = attributes[key].to_s.downcase
      value.blank? || entry.send(key).downcase.include?(value)
    end
  end

  def self.entries
    [
        new_entry("1", "Art", "Andrews", "art@example.com", "999-999-0001", "Dept 1"),
        new_entry("2", "Beth", "Brown", "beth@example.com", "999-999-0002", "Dept 2"),
        new_entry("61065", "Steven", "Hansen", "runner@berkeley.edu", "999-999-9998", "EAS"),
        new_entry("191501", "Steve", "Downey", "sldowney@berkeley.edu", "999-999-9999", "EAS"),
    ]
  end

  def self.new_entry(uid, fn, ln, email, phone, depts)
    LdapPersonEntry.new(
        :ldap_uid => uid,
        :first_name => fn,
        :last_name => ln,
        :email => email,
        :ucbemail => "ucb" + email,
        :phone => phone,
        :departments => depts,
        :affiliations => ["EMPLOYEE-TYPE-STAFF"]
    )
  end

end
