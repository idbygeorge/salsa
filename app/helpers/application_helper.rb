module ApplicationHelper
  def salsa_partial(name, org=@organization)
    path_info = name.split '/'

    path = ''
    partial = name

    if path_info.size > 1 then
      partial = path_info.pop
      path = path_info.join('/') + '/'
    end

    view_folder = get_view_folder org

    #phase 2, make this dynamic?
    #dynamic scss/erb - http://microblog.anthonyestebe.com/2014-04-28/compile-your-scss-according-to-your-model-on-rails/
    #need a way to control who can do this though... or how much?

    # if this document is using a configuration and that configuration has the partial being requested, use it
    if org && org.components && org.components.find_by(slug: name)
      output = org.components.find_by(slug: name).layout
    # if there is a customized partial for this organization, use that
    elsif view_folder && File.exists?("app/views/#{view_folder}/#{path}_#{partial}.html.erb")
      output = render partial: "#{view_folder}/#{path}#{partial}"
    # do nothing (this allows there to be additional configs added that don't have a default)
    else
      output = ''
    end

    if output == ''
      # if there is a parent, recheck using it as the org
      if org.parent
        output = salsa_partial(name, org.parent)
      elsif org.slug.include? '/'
        output = salsa_partial(name, Organization.new(slug: org.slug.gsub(/\/[^\/]+$/, '')))
      # otherwise, show the default if it exists
      elsif File.exists?("app/views/instances/default/#{path}_#{partial}.html.erb")
        output = render partial: "instances/default/#{path}#{partial}"
      end
    end

    return output.html_safe
  end

  def get_view_folder(org) 
    # only update the view folder if the institution folder exists
    "instances/custom/#{org.slug}" if File.directory?("app/views/instances/custom/#{org.slug}")
  end

  def require_admin_password
    # if there is no admin password set up for the server and we are in the development
    # or test environment, bypass the securtiy check
    if !APP_CONFIG['admin_password'] && (Rails.env.development? || Rails.env.test?)
      session[:admin_authorized] = true
    elsif params[:admin_password] && params[:admin_password] != ''
      session[:admin_authorized] = params[:admin_password] == APP_CONFIG['admin_password']
    end

    if !has_role 'admin'
      redirect_to root_path
    end
  end

  def has_role role
    result = false

    if role == 'admin'
      result = session[:admin_authorized]
    end

    result
  end
end
