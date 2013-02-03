# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper

  def title(page_title, sub_title=nil)
    @page_title = page_title.gsub(/<.*?>/, '')
    result      = "<h1>#{page_title}"
    result += " &nbsp;<small>#{sub_title}</small>" if sub_title
    result += "</h1>"
    result.html_safe
  end

end
