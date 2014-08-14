module ApplicationHelper
  def salsa_partial(name)
    #phase 2, make this dynamic?
    #dynamic scss/erb - http://microblog.anthonyestebe.com/2014-04-28/compile-your-scss-according-to-your-model-on-rails/
    #need a way to control who can do this though... or how much?

    # if this document is using a configuration and that configuration has the partial being requested, use it
    if @document && @document.component && @document.component[name]
      output = @document.component[name]
    # if there is a customized partial for this organization, use that
    elsif @view_folder && File.exists?("app/views/#{@view_folder}/_#{name}.html.erb")
      output = render partial: "#{@view_folder}/#{name}"
    # otherwise, show the default if it exists
    elsif File.exists?("app/views/instances/default/_#{name}.html.erb")
      output = render partial: "instances/default/#{name}"
    # do nothing (this allows there to be additional configs added that don't have a default)
    else
      output = ''
    end

    return output.html_safe
  end
end
