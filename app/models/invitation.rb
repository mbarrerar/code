class Invitation < ActiveForm
  column :from_email
  column :from_name
  column :to_email
  column :site_url
  column :message

  validates_format_of :to_email, :from_email,
  :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
  :allow_blank => true
  validates_presence_of :to_email, :from_email, :from_name, :site_url


  def from=(user)
    @from = user
  end

  def from_name()
    @from.full_name()
  end

  def from_email()
    @from.email()
  end

  def self.msg_success(invitation)
    "Invitation sent to: <strong>#{invitation.to_email}</strong>. Check your email for further instructions."
  end

  def self.msg_error(invitation)
    invitation.errors.full_messages.join("<br/>")
  end
end
