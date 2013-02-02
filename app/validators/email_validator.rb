class EmailValidator < ActiveModel::EachValidator

  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def validate_each(object, attribute, value)
    unless value =~ EMAIL_REGEXP
      object.errors[attribute] << "is invalid"
      return
    end
  end

end
