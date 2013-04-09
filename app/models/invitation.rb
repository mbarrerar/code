class Invitation
  include ActiveModel::Validations
  include ActiveAttr::Model

  attribute :from_email
  attribute :from_name
  attribute :to_email
  attribute :site_url
  attribute :message

  validates :to_email, :from_email, :email => { allow_blank: true, present: true }
  validates_presence_of :from_name, :site_url


  def from=(user)
    @from = user
  end

  def from_name
    @from.full_name
  end

  def from_email
    @from.email
  end

  def self.msg_success(invitation)
    "Invitation sent to: <strong>#{invitation.to_email}</strong>. Check your email for further instructions."
  end

  def self.msg_error(invitation)
    invitation.errors.full_messages.join("<br/>")
  end
end
