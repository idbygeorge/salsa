class AdminController < ApplicationController
  before_filter :require_admin_password

  def login
  	@organization = find_org_by_path params[:slug]

  	if @organization and @organization[:lms_authentication_source]
  		@callback_url = organizations_url

  		canvas_connection_information

  		redirect_to @redirect_url if @redirect_url

		redirect_to @callback_url if @lms_user
	else
  		render action: :login, layout: false
  	end
  end

  def logout
    session[:admin_authorized] = false

    redirect_to root_path;
  end

  def search page=params[:page], per=25
    @documents = Document.where("lms_course_id = '#{params[:q]}' OR name LIKE '%#{params[:q]}%' OR edit_id LIKE '#{params[:q]}%' OR view_id LIKE '#{params[:q]}%' OR template_id LIKE '#{params[:q]}%' OR payload LIKE '%#{params[:q]}%'").page(page).per(per)
  end


  def canvas_connection_information
    redirect_port = ':' + request.env['SERVER_PORT'] unless ['80', '443'].include?(request.env['SERVER_PORT'])

    # custom authentication source, use the keys from the DB
    if @organization && @organization[:lms_authentication_source] != ''
      @oauth_endpoint = @organization[:lms_authentication_source] unless @organization[:lms_authentication_source] == ''
      @lms_client_id = @organization[:lms_authentication_id] unless @organization[:lms_authentication_id] == ''
      @lms_secret = @organization[:lms_authentication_key] unless @organization[:lms_authentication_key] == ''
    end
    
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

      @redirect_url = "#{@lms_client.oauth_url(@callback_url)}"
    end
  end
end
