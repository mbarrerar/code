module CrudMessage
  def msg_errors(obj)
    obj.errors.full_messages {}
  end

  def msg_created(obj)
    "#{msg_prefix(obj)} created"
  end

  def msg_destroyed(obj)
    "#{msg_prefix(obj)} deleted."
  end

  def msg_updated(obj)
    "#{msg_prefix(obj)} updated"
  end

  def msg_prefix(obj)
    "#{obj.instance_of?(String) ? obj : obj.class.to_s} successfully"
  end
end