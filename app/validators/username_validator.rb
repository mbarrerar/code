class UsernameValidator < ActiveModel::EachValidator

  USERNAME_REGEXP = /\A(\S)+\Z/i

  def validate_each(object, attribute, value)
    unless value =~ USERNAME_REGEXP
      object.errors[attribute] << "is invalid"
      return
    end
  end

end
