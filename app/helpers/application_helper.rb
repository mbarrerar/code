# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include BreadCrumbHelper
  include IconHelper
  include CssHelper

  def logged_in_content(&block)
    yield if logged_in?
  end

  def logged_out_content(&block)
    yield unless logged_in?
  end

  def form_actions(&block)
    content_tag(:div, :class => 'form-controls') do
      yield
    end
  end

  def delete_button(object)
    link_to('Delete', object, :method => :delete, :remote => true, :confirm => 'Are you sure?', :class => 'btn btn-mini btn-danger')
  end

  def save_button(f)
    f.button(:submit, 'Save', :class => 'btn-primary', :disable_with => 'Saving ...')
  end

  def link_to_delete(ar_instance, html_options = {})
    default_options = { :confirm => 'Are you sure?', :method => :delete, :class => 'btn btn-mini btn-danger' }
    link_to('Delete', ar_instance, default_options.merge!(html_options))
  end

  def link_to_new(name, options = {}, html_options = {})
    html_options.merge!(:class => 'btn btn-primary btn-small')
    link_to(name, options, html_options) + content_tag(:br)
  end

  def link_to_cancel(options = {}, html_options = {})
    link_to('Cancel', options, html_options)
  end

  def link_to_edit(options = {}, html_options = {})
    default_options = { :class => "btn btn-mini" }
    name = "<i class='icon-edit'></i> edit".html_safe
    link_to(name, options, default_options.merge!(html_options))
  end

  def link_to_disk_reload(space_name, repo_name)
    url = url_for(:controller => "api/repository_stats",
                  :action => "calc_disk_usage",
                  :space_name => space_name,
                  :repo_name => repo_name)
    name = "<i class='icon-refresh'></i> ".html_safe
    link_to(name, url)
  end

  def link_to_admin(options = {}, html_options = {})
    default_options = { :class => 'mini_button_widget' }
    link_to('Admin', options, default_options.merge!(html_options))
  end

  def delete_button_to(ar_instance, options = {}, html_options = {})
    label = options.delete(:label) || "Delete #{ar_instance.class.name.humanize}"
    default_options = { :confirm => 'Are you sure?', :method => :delete, :class => 'btn btn-danger' }
    content_tag(:div, :class => 'pull-right', :style => 'margin-top: 4em;') do
      link_to(label, ar_instance, default_options.merge!(html_options))
    end
  end

  def space_repo_text(repo)
    "#{repo.space.name} / #{repo.name}"
  end

  ##
  # Returns a "check-mark" if _boolean_ is +true+.
  #
  # @param [Boolean]
  # @return [String] the checkbox
  #
  def boolean_check_mark(boolean)
    boolean ? content_tag(:span, image_tag('check.png', :alt => 'true', :size => '20x20')) : ''
  end

  def flash_messages
    return nil if flash.empty?
    result = []
    flash.each do |name, msg|
      result << build_message(name, msg)
    end
    result.join.html_safe
  end

  def build_message(msg_type, msg)
    content_tag(:div, :class => "alert alert-#{msg_type.to_s}") do
      content_tag(:a, 'x', :class => 'close', 'data-dismiss' => 'alert') + msg.html_safe
    end
  end

  def nav_li(item, current)
    link = link_to(item[:label], item[:url], :id => item[:dom_id])
    klass = current.to_s == item[:id].to_s ? 'current' : ''
    content_tag(:li, link, :class => klass)
  end

  def account_major_tabs
    TabNav::TabSet.new(self, :name => :major, :layout => :horizontal) do |ts|
      ts.add(:profile, edit_profile_url)
      ts.add(:ssh_keys, ssh_keys_url)
      ts.add(:spaces, spaces_url)
      ts.add(:repositories, repositories_url)
    end
  end

  ##
  # By default, no minor tabs.  Other helpers override this method to provide tabs.
  #
  def minor_tabs
    nil
  end

  ##
  # Returns the html for minor_tabs().  See ApplicationController::no_minor_tabs() to see how
  # to suppress minor tabs.
  #
  def minor_tabs_html
    unless @no_minor_tabs
      minor_tabs.try(:html)
    end
  end

  ##
  # Display size of repo/space as read-only field
  #
  def size_display(form_helper)
    unless form_helper.object.new_record?
      form_helper.input :size_display, :label => 'Size', :input_html => { :disabled => true }
    end
  end

  def ssh_banner
    if current_user.try(:has_no_ssh_keys?)
      link = link_to('upload an SSH key', ssh_keys_url)
      message = "To use any EZ SVN repositories you need to #{link}."
      content_tag(:div, message, :id => 'ssh_banner')
    end
  end
end
