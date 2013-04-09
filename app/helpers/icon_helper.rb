module IconHelper

  def icon(type, options = {})
    icon_class = "icon-#{type.to_s.gsub("_", "-")}"
    text = options.delete(:text)
    options[:class] = Array(options[:class]) << icon_class
    result = content_tag(:i, nil, options)
    result << content_tag(:span, " #{text}", class: 'ikon-text') if text.present?
    result
  end

  def icon_delete(options = {})
    icon('trash', options)
  end

  def icon_date(options = {})
    icon('calendar', options)
  end

  def icon_edit(options = {})
    icon('pencil', options)
  end

  def icon_email(options = {})
    icon('envelope', options)
  end

  def icon_search(options = {})
    icon('search', options)
  end

end
