module ApplicationHelper
  include ActionView::Helpers::UrlHelper

  def salsa_partial(name, org=@organization, parent_org=nil)
    @organization = org
    path_info = name.split '/'

    path = ''
    partial = name

    if parent_org != nil
      component_org = parent_org
    else
      component_org = org
    end

    if path_info.size > 1 then
      partial = path_info.pop
      path = path_info.join('/') + '/'
    end
    view_folder = get_view_folder component_org

    #phase 2, make this dynamic?
    #dynamic scss/erb - http://microblog.anthonyestebe.com/2014-04-28/compile-your-scss-according-to-your-model-on-rails/
    #need a way to control who can do this though... or how much?

    # if this document is using a configuration and that configuration has the partial being requested, use it
    if component_org && component_org.components && component = component_org.components.find_by(slug: name)
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
      if component_org&.parent
        output = salsa_partial(name, org, org.parent)
      elsif component_org&.slug&.include? '/'
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

  def require_approver_permissions
    check_for_admin_password

    unless has_role 'approver'
      return redirect_or_error
    end
  end


  def require_supervisor_permissions
    check_for_admin_password

    unless has_role 'supervisor'
      return redirect_or_error
    end
  end

  def require_staff_permissions
    check_for_admin_password

    unless has_role('staff') || has_role('supervisor') || has_role('approver')
      return redirect_or_error
    end
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
    unless has_role('designer') || has_role('organization_admin') || has_role('supervisor')
      return redirect_or_error
    end
  end

  def require_auditor_role
    unless has_role('auditor') || has_role('designer') ||  has_role('organization_admin')
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
      if current_page?(admin_path(org_path: params[:org_path]))
        flash.keep
        return redirect_to admin_login_path(org_path: params[:org_path])
      else
        return redirect_to admin_path(org_path: params[:org_path])
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

  def get_user_assignment_org user_id, role
    if user_id != nil
      current_user = User.find(user_id)
      if current_assignment = current_user.user_assignments.find_by(role: role)
        return current_assignment.organization
      else
        return nil
      end
    end
  end

  def has_role (role, org=nil)
    unless org
      if params[:slug]
        org = find_org_by_path params[:slug]
      else
        org = find_org_by_path get_org_path
      end
    end

    result = false

    # # if they are authorized as an admin, let them in
    if session[:admin_authorized] == true
      return result = true
    elsif !org && (session[:saml_authenticated_user] == nil || session[:authenticated_user] == nil)
      return result
    end

    user_assignments = nil
    if get_org&.root_org_setting("enable_shibboleth") && session[:saml_authenticated_user]
      username = session[:saml_authenticated_user]['id'].to_s
      user_assignments = UserAssignment.where('organization_id in (?) OR (role = ?)', org.self_and_ancestors.pluck(:id), 'admin').where("lower(username) = ? OR user_id = ?", username.downcase, session[:authenticated_user])
    elsif org&.root_org_setting("lms_authentication_source") && org&.root_org_setting("lms_authentication_source") == session[:oauth_endpoint] && session[:saml_authenticated_user]
      username = session[:saml_authenticated_user]['id'].to_s
      user_assignments = UserAssignment.where('organization_id in (?) OR (role = ?)', org.self_and_ancestors.pluck(:id), 'admin').where("lower(username) = ?", username.downcase)
    else
      user_assignments = UserAssignment.where('organization_id IN (?) OR (role = ?)', org&.self_and_ancestors.pluck(:id), 'admin').where(user_id: session[:authenticated_user])
    end

    user_assignments&.each do |ua|
      if (ua[:role] == role || ua[:role] == 'admin') && (ua.cascades == false && ua.organization_id == org.id)
        result = true
      elsif (ua[:role] == role || ua[:role] == 'admin') && ua.cascades == true
        result = true
      end

      # if we aren't looking for an admin role, but the user has organization admin permissions, then they have permissions for this role
      if role != 'admin' && ua[:role] == 'organization_admin'
        result = true
      end
    end

    result
  end

  def get_organizations
    if session[:saml_authenticated_user]
      user = UserAssignment.find_by("lower(username) = ?", session[:saml_authenticated_user]["id"].to_s.downcase).user
    elsif session[:authenticated_user]
      user = User.find session[:authenticated_user]
    end

    # only show orgs that the logged in user should see
    unless session[:admin_authorized] || user&.user_assignments&.find_by(role: "admin")
      # load all orgs that the user has a cascade == true assignment

      cascade_permissions = user&.user_assignments&.where(cascades: true)
      cascade_organizations = Organization.where(id: cascade_permissions&.map(&:organization_id))

      filter_query = ['id IN (?)']
      filter_values = [user&.user_assignments&.map(&:organization_id)]

      cascade_organizations&.each do |org|
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
    org.full_org_path
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
    path = get_org_path unless path

    unless path&.include? '/'
      organization = Organization.find_by slug:path
    else
      path.split((/(?=\/)/)).each do |slug|
        next if slug.blank?
        unless organization
          organization = Organization.find_by slug: slug, depth: 0
        else
          org = organization.descendants.find_by slug: slug
          org = organization.descendants.find_by slug: slug.remove("/") if org.blank?
          organization = org
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

  def get_org_path
    return request.env['SERVER_NAME'] + '/' + params[:org_path] if params[:org_path]
    return request.env['SERVER_NAME']
  end

  def get_org_slug
    organization = find_org_by_path(get_org_path)
    return get_org_path if organization.blank?
    organization&.slug
  end

  def get_org
    find_org_by_path(get_org_path)
  end

  def get_document_meta
    org_slug = get_org_slug
    ReportHelper.get_document_meta org_slug, nil, params
  end
end
