module ApplicationHelper
  def salsa_partial(name)
    path_info = name.split '/'

    path = ''
    partial = name

    if path_info.size > 1 then
      partial = path_info.pop
      path = path_info.join('/') + '/'
    end

    #phase 2, make this dynamic?
    #dynamic scss/erb - http://microblog.anthonyestebe.com/2014-04-28/compile-your-scss-according-to-your-model-on-rails/
    #need a way to control who can do this though... or how much?

    # if this document is using a configuration and that configuration has the partial being requested, use it
    if @organization && @organization.components && @organization.components.find_by(slug: name)
      output = @organization.components.find_by(slug: name).layout
    # if there is a customized partial for this organization, use that
    elsif @view_folder && File.exists?("app/views/#{@view_folder}/#{path}_#{partial}.html.erb")
      output = render partial: "#{@view_folder}/#{path}#{partial}"
    # otherwise, show the default if it exists
    elsif File.exists?("app/views/instances/default/#{path}_#{partial}.html.erb")
      output = render partial: "instances/default/#{path}#{partial}"
    # do nothing (this allows there to be additional configs added that don't have a default)
    else
      output = ''
    end

    return output.html_safe
  end
end
