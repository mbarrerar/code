class EntityNameValidator < ActiveModel::EachValidator

  ENTITY_NAME_REGEXP = /^[\w\-]+$/
  ENTITY_NAME_ERROR_MESSAGE = 'can only contain letters, numbers, "_" and "-"'

  def validate_each(object, attribute, value)
    unless value =~ ENTITY_NAME_REGEXP
      object.errors[attribute] << ENTITY_NAME_ERROR_MESSAGE
      return
    end
  end

end
