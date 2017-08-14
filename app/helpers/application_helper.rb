module ApplicationHelper
  include ActionView::Helpers::UrlHelper

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
      component = org.components.find_by(slug: name)
      output = component.layout

      if APP_CONFIG['allow_erb_components'] && component.format == 'erb'
        output = ERB.new(output).result(binding)
      end

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

    if output == '' && has_role('admin') && partial != 'analytics'
      output = "#{path}#{partial} does not exist"
    end

    return output.html_safe
  end

  def get_view_folder(org)
    # only update the view folder if the institution folder exists
    "instances/custom/#{org.slug}" if File.directory?("app/views/instances/custom/#{org.slug}")
  end

  def require_admin_permissions
    check_for_admin_password

    unless has_role 'admin'
      return redirect_or_error
    end
  end

  def require_organization_admin_permissions
    check_for_admin_password

    unless has_role 'organization_admin'
      return redirect_or_error
    end
  end

  def require_designer_permissions
    unless has_role('designer') || has_role('organization_admin')
      return redirect_or_error
    end
  end

  def require_auditor_role
    unless has_role('auditor')  || has_role('organization_admin')
      return redirect_or_error
    end
  end

  def require_organization_admin_role
    unless has_role 'organization_admin'
      return redirect_or_error
    end
  end

  def redirect_or_error
    if session[:authenticated_user]
      return render :file => "public/401.html", :status => :unauthorized, :layout => false
    else
      if current_page?(admin_path)
        return redirect_to admin_login_path
      else
        return redirect_to admin_path
      end
    end
  end

  def check_for_admin_password
    # if there is no admin password set up for the server and we are in the development
    # or test environment, bypass the securtiy check
    if params[:admin_off] == "true"
      session[:admin_authorized] = false
    elsif !APP_CONFIG['admin_password'] && (Rails.env.development? || Rails.env.test?)
      session[:admin_authorized] = true
    elsif params[:admin_password] && params[:admin_password] != ''
      session[:admin_authorized] = params[:admin_password] == APP_CONFIG['admin_password']
    end
  end

  def has_role (role, org=nil)
    unless org
      if params[:slug]
        org = find_org_by_path params[:slug]
      else
        org = find_org_by_path request.env['SERVER_NAME']
      end
    end

    result = false

    # # if they are authorized as an admin, let them in
    if session[:admin_authorized] == true
      result = true
    elsif org && (session[:lms_authenticated_user] != nil || session[:authenticated_user] != nil)
      if org[:lms_authentication_source] && org[:lms_authentication_source] == session[:oauth_endpoint]
        username = session[:lms_authenticated_user]['id'].to_s
        user_assignments = UserAssignment.where('organization_id = ? OR (role = ?)', org[:id], 'admin').where(username: username)
      else
        user_assignments = UserAssignment.where('organization_id = ? OR (role = ?)', org[:id], 'admin').where(user_id: session[:authenticated_user])
      end

      if user_assignments.count > 0
        user_assignments.each do |ua|
          if ua[:role] == role or ua[:role] == 'admin'
            result = true
          end

          # if we aren't looking for an admin role, but the user has organization admin permissions, then they have permissions for this role
          if role != 'admin' && ua[:role] == 'organization_admin'
            result = true
          end
        end
      end
    end

    result
  end

  def get_organizations
    # only show orgs that the logged in use should see
    unless session[:admin_authorized]
      # load all orgs that the user has a cascade == true assignment
      if session[:lms_authenticated_user]
        user = UserAssignment.find_by_username(
          session[:lms_authenticated_user]['id'].to_s
        ).user
      elsif session[:authenticated_user]
        user = User.find session[:authenticated_user]
      end

      cascade_permissions = user.user_assignments.where(cascades: true)
      cascade_organizations = Organization.where(id: cascade_permissions.map(&:organization_id))

      filter_query = ['id IN (?)']
      filter_values = [user.user_assignments.map(&:organization_id)]

      cascade_organizations.each do |org|
        filter_query.push '(lft > ? AND rgt < ?)'
        filter_values.push org.lft
        filter_values.push org.rgt
      end

      filter_querystring = filter_query.join(' OR ')

      @organizations = Organization.where(filter_querystring, *filter_values)
    else
      @organizations = Organization.all.order(:lft, :rgt, :name)
    end
  end

  def full_org_path org
    if org[:depth] > 0 and org[:slug].start_with? '/'
      org_slug = org.self_and_ancestors.pluck(:slug).join ''
    else
      org_slug = org[:slug]
    end

    org_slug
  end

  def org_slug_parts org
    org_slug = full_org_path(org)

    if org_slug
      parts = org_slug.split '/', 2
    end

    parts = ['', ''] unless parts

    parts
  end

  def find_org_by_path path
    path = request.env['SERVER_NAME'] unless path

    unless path.include? '/'
      organization = Organization.find_by slug:path
    else
      path.split('/').each do |slug|
        unless organization
          organization = Organization.find_by slug: slug, depth: 0
        else
          organization = organization.children.find_by slug: "/" + slug
        end
      end
    end

    organization
  end

  def redirect_port
    ':' + request.env['SERVER_PORT'] unless ['80', '443'].include?(request.env['SERVER_PORT'])
  end

  def check_lock path, batch_token
    organization = Organization.find_by slug:path
    if(organization.republish_at)
      if ((DateTime.now - organization.republish_at.to_datetime)*24).to_i > 4
        organization.republish_at = nil
        organization.republish_batch_token = nil

        organization.save!

        return true
      elsif organization.republish_batch_token != batch_token
        return false
      end
    end

    return true
  end

  def get_org_slug
    request.env['SERVER_NAME']
  end

  def get_org
    Organization.find_by slug: get_org_slug
  end

  def get_document_meta
    org_slug = request.env['SERVER_NAME']
    ReportHelper.get_document_meta org_slug, 'FL16', params
  end
end
