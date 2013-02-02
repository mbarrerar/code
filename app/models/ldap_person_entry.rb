class LdapPersonEntry
  include ActiveAttr::Model

  attribute :ldap_uid
  attribute :first_name
  attribute :last_name
  attribute :email
  attribute :ucbemail
  attribute :phone
  attribute :departments
  attribute :affiliations


  def full_name
    [first_name, last_name].join(" ")
  end
end
