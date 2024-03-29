module TabNav #:nodoc:
  # Class for modeling a navigation tab.
  #
  # To simplify the API documentation all but the new method have had RDOC
  # suppressed.  Have a look at the source if you need finer-grained control
  # over Tab instances.
  class Tab
    # Returns new instance of Tab.
    #
    #   home_tab = TabNav::Tab.new(:home, "/home")
    #
    # Options:
    # * :label - the text on the tab; defaults to +name+
    # * :title - "title" attribute on <li> tag; defaults to "Go to: <url>"
    # * :css_class - "class" attribute on <li> tag; defaults to "tab-item" -- anything
    #   you pass will be _added_ to the default class
    # * :dom_id - "id" attribute on <li> tag; defaults to "tab-item-<name>"
    #
    # Using all the options:
    #
    #  home_tab = TabNav::Tab.new(:about, "/about", {
    #    :label     => "About Us",
    #    :title     => "Learn more about our team",
    #    :css_class => "internal-link",
    #    :dom_id    => "about-us"
    #  })
    def initialize(name, url, options = {})
      @name = name
      @url = url
      @options = options
      @lockable = options[:lockable]
      @disabled = false
      @data_attributes = {}
    end
    
    def name #:nodoc:
      @name
    end
    
    def url #:nodoc:
      @url
    end
    
    def options #:nodoc:
      @options
    end
    
    def tab_set=(ts) #:nodoc:
      @tab_set = ts
    end
    
    def tab_set #:nodoc:
      @tab_set
    end
    
    def css_class #:nodoc:
      options[:css_class]
    end
    
    def dom_id #:nodoc:
      options[:dom_id] || name.to_s.downcase.gsub(" ", "-")
    end
    
    def label #:nodoc:
      options[:label] || name.to_s
    end
    
    def title #:nodoc:
      which = current? ? "You are at" : "Go to"
      title = options[:title] || "WHICH: #{url}"
      title.sub("WHICH", which)
    end

    def add_data(key, val=true)
      data_attributes["data-#{key}"] = val
    end

    def data_attributes
      @data_attributes
    end

    def lockable?
      @lockable
    end

    def disabled?
      @disabled
    end

    def disable
      @disabled = true
    end

    def current? #:nodoc:
      tab_set.current_tab.to_s.downcase == name.to_s.downcase
    end
    
    # This method raises a RuntimeError if it is called before the Tab is attached to a TabSet.
    def html #:nodoc:
      raise("TabNav::Tab can't return html until attached to a TabNav::TabSet") unless tab_set.instance_of?(TabSet)
      options = {:class => html_li_class, :id => dom_id, :title => title}.merge(data_attributes)
      content_tag(:li, html_content, options)
    end
    
    def html_content #:nodoc:
      if disabled?
        content_tag(:span, label)
      elsif current? && display_current_tab_as_text?
        content_tag(:span, label)
      else
        link_name = label.titleize
        if tab_set.layout_vertical?
          link_name += "<i class='icon-chevron-right pull-right'></i>".html_safe
        end
        link_to(link_name.html_safe, url)
      end
    end
    
    def html_li_class #:nodoc:
      current? ? "active" : css_class
    end
    
    def method_missing(*args, &block) #:nodoc:
      tab_set.send(*args, &block)
    end
    
  end
  
end
