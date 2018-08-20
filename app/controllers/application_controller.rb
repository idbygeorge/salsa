class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :redirect_if_user_archived, except:[:logout]

  include ApplicationHelper

  protected

  def redirect_if_user_archived
    if session[:authenticated_user]
      user = User.find_by(id: session[:authenticated_user], archived: false)
      if !user
        flash[:notice] = "You have been logged out because your account has been deactivated"
        redirect_to admin_logout_path
      end
    end

  end

  def component_allowed_liquid_variables step_slug, user=nil, organization=nil
    hash = {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{organization&.name}"}
    hash["step_slug"] = "#{step_slug}" if step_slug != nil
    return hash
  end

  def check_organization_workflow_enabled
    if params[:slug]
      organization = Organization.find_by(slug: params[:slug])
    else
      organization = Organization.find_by(slug: request.env["SERVER_NAME"])
    end
    if organization&.enable_workflows != true
      flash[:error] = "that page does not exist"
      redirect_to organization_path(params[:slug])
    end
  end

  def current_user
    if session[:authenticated_user]
      User.find_by(id: session[:authenticated_user], archived: false)
    end
  end

  def get_roles
    @roles = UserAssignment.roles
  end

  def init_view_folder
    @google_analytics_id = APP_CONFIG['google_analytics_id'] if APP_CONFIG['google_analytics_id']

    org_slug = request.env['SERVER_NAME']

    if params[:sub_organization_slugs]
      org_slug += '/' + params[:sub_organization_slugs]
    end

    # find the matching organization based on the request
    @organization = Organization.find_by slug: org_slug

    # get a placeholder org matching the org slug if there is no matching or in the database
    @organization = Organization.new  slug: org_slug unless @organization

    @view_folder = get_view_folder @organization
    @view_folder = "instances/default" unless @view_folder
  end

  def lms_connection_information
    if session[:institution] && session[:institution] != ''
      @institution = session['institution']
    elsif !params[:institution] || params[:institution] == ''
      @institution = request.env['SERVER_NAME']
    else
      @institution = params[:institution]
    end

    @organization = Organization.find_by slug: @institution unless @organization

    redirect_port = ':' + request.env['SERVER_PORT'] unless ['80', '443'].include?(request.env['SERVER_PORT'])

    # custom authentication source, use the keys from the DB
    if @organization && @organization[:lms_authentication_source] != ''
      @oauth_endpoint = @organization[:lms_authentication_source] unless @organization[:lms_authentication_source] == ''
      @lms_client_id = @organization[:lms_authentication_id] unless @organization[:lms_authentication_id] == ''
      @lms_secret = @organization[:lms_authentication_key] unless @organization[:lms_authentication_key] == ''
      @callback_url = "http://#{@organization[:slug]}#{redirect_port}/oauth2/callback" unless @organization[:slug] == ''
    end

    # defaults
    @oauth_endpoint = "https://#{@institution}.instructure.com" unless @oauth_endpoint
    @lms_client_id = APP_CONFIG['canvas_id'] unless @lms_client_id
    @lms_secret = APP_CONFIG['canvas_key'] unless @lms_secret
    @callback_url = "http://#{request.env['SERVER_NAME']}#{redirect_port}/oauth2/callback" unless @callback_url

    if canvas_access_token && canvas_access_token != ''
      @lms_client = Canvas::API.new(:host => @oauth_endpoint, :token => canvas_access_token)

      # if this throws an error, there is something wrong with the token
      begin
        @lms_user = @lms_client.get("/api/v1/users/self/profile") if @lms_client.token
      rescue
        # clear the session and start over
        redirect_to oauth2_logout_path
      end
    elsif @lms_client_id
      @lms_client = Canvas::API.new(:host => @oauth_endpoint, :client_id => @lms_client_id, :secret => @lms_secret)

      if params[:lms_course_id]
        if params[:document_token]
          @redirect_url = "#{@lms_client.oauth_url(@callback_url)}%3Flms_course_id%3D#{params[:lms_course_id]}%26document_token%3D#{params[:document_token]}"
        else
          @redirect_url = "#{@lms_client.oauth_url(@callback_url)}%3Flms_course_id%3D#{params[:lms_course_id]}"
        end
      else
        @redirect_url = "#{@lms_client.oauth_url(@callback_url)}%3Fdocument_id%3D#{params[:document_id]}"
      end
    end
  end

  def canvas_access_token
    session[:canvas_access_token]["access_token"] if session[:canvas_access_token]
  end
end
