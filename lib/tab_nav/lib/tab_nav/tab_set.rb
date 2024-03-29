module TabNav #:nodoc:
  # Class for modeling a set of navigation tabs.
  #
  # To simplify the API documentation most methods have had RDOC
  # suppressed.  Have a look at the source if you need finer-grained control
  # over TabSet instances.
  class TabSet
    # call-seq: 
    #   new(template, options = {}, &block)
    #
    # Returns new instance of TabSet.
    #
    # === Examples
    #
    # Create TabSet instance -- need to add Tab's later with #add()
    #
    #   # in a view helper
    #   # must pass in instance of ActionView::Base, i.e. "self" in view or helper
    #
    #   tab_nav = TabNav::TabSet.new(self)
    #
    #   # add a TabNav::Tab instance
    #
    #   tab_nav.add(TabNav::Tab(:home, "/home"))
    #
    #   # pass TabNav::Tab#new()'s arguments to TabNav::TabSet#add():
    #
    #   tab_nav.add(:about, "/about")
    #
    # Attach Tab's in contructor:
    #
    #   tabs = [
    #     TabNav::Tab.new(:home, "/home"),
    #     TabNav::Tab.new(:about, "/about")
    #   ]
    #   tab_nav = TabNav::TabSet.new(self, :tabs => tabs)
    #
    # Or using block:
    #
    #   tab_nav = TabNav::TabSet.new(self, :tabs => tabs) do |ts|
    #     ts.add TabNav::Tab.new(:home, "/home")
    #     ts.add :about, "/about"
    #   end
    #
    # === Options
    # * :name - defaults to <tt>:default</tt>
    # * :tabs - an Array of TabNav::Tabs
    # * :css_class - "class" attribute on <ul> tag; defaults to "tab-set" -- anything
    #   you pass will be _added_ to the default class
    # * :dom_id - "id" attribute on <ul> tag; defaults to "tab-set-<name>"
    # * :display_current_tab_as_text - default is +false+.  If set to +true+ then the
    #   current tab is rendered as text rather than as a link.
    def initialize(template, options = {}, &block)
      raise(ArgumentError, "Expected ActionView::Base, got #{template.class}") unless template.is_a?(ActionView::Base)
      @template = template
      @name = options.delete(:name) || :default
      tabs = options.delete(:tabs) || []
      tabs.each { |tab| add(tab) }
      @dom_id = options.delete(:dom_id) || name.to_s.downcase.gsub(" ", "-")
      @layout = options.delete(:layout) || :vertical
      @display_current_tab_as_text = options.delete(:display_current_tab_as_text)
      raise(ArgumentError, "Unknown option(s) passed: #{options.inspect}") unless options.blank?
      yield self if block_given?
    end
    
    def template #:nodoc:
      @template
    end
    
    def name #:nodoc:
      @name
    end

    def options #:nodoc:
      @options
    end
    
    # call-seq: 
    #   add(tab)
    #   add(tab_name, tab_url, tab_options => {})
    #
    # The first calling sequence is used when you are adding instances of TavNav::Tab:
    #
    #   tab = TabNav::Tab(:home, "/home")
    #   tab_set.add tab
    #
    # The second calling sequence is used to let the tab set implicitly create TabNav::Tab's
    # as a side-affect.  The arguments are the same as for TabNav::Tab.new:
    #
    #   tab_set.add :home, "/home", :label => "Home Page"
    #
    def add(*args)
      if args.length == 1
        tab = args[0]
      else
        tab = Tab.new(*args)
      end
      tab.tab_set = self
      tabs << tab
    end

    def [](name)
      @tabs.detect { |t| t.name == name }
    end

    def tabs #:nodoc:
      @tabs ||= []
    end
    
    def css_class #:nodoc:
      if @layout == :vertical
        "nav nav-tabs nav-stacked nav-pills"
      elsif @layout.to_sym == :horizontal
        "nav nav-tabs"
      else
        raise(StandardError, "Unrecognized TabNav layout: #{@layout.to_s}")
      end
    end

    def layout_vertical?
      @layout == :vertical
    end

    def layout_horizontal?
      @layout == :horizontal
    end

    def dom_id #:nodoc:
      @dom_id
    end
    
    def display_current_tab_as_text? #:nodoc:
      @display_current_tab_as_text
    end

    def disable_lockable_tabs
      @tabs.each { |t| t.disable if t.lockable? }
    end

    # Returns the html for this tab set as an unordered list; example assumes 
    # current tab is set to <tt>:home</tt>:
    #
    #   <ul class="tab-set" id="tab-set-default">
    #     <li class="tab-item-current" id="tab-home" title="You are at: /home"><span>Home</span></li>
    #     <li id="tab-project" title="Go to: /projects"><a href="/projects">Project</a></li>
    #     <li id="tab-about" title="Go to: /about"><a href="/about">About</a></li>
    #   </ul>
    def html
      content = tabs.map(&:html).join("\n")
      content_tag(:ul, content.html_safe, :class => css_class, :id => dom_id)
    end

    def current_tab #:nodoc:
      current_tabs[name] || current_tabs[:default]
    end
    
    def method_missing(*args, &block) #:nodoc:
      template.send(*args, &block)
    end
    
  end
  
end
