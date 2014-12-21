class AdminController < ApplicationController
  before_filter :require_admin_password
  before_filter :get_organizations, only: [:search]

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

  def canvas
    @report_data = DocumentMeta.where key: [:name, :id, :enrollment_term_id, :workflow_state, :account_id, :course_id]

    render 'canvas', layout: '../admin/report_layout'
  end

  def canvas_accounts
    org_slug = request.env['SERVER_NAME']
    @org = Organization.find_by slug: org_slug

    @org_meta = OrganizationMeta.where root_id: @org['id']

    render 'admin/canvas/accounts'
  end

  def canvas_courses
    org_slug = request.env['SERVER_NAME']
    @org = Organization.find_by slug: org_slug

    @document_meta = DocumentMeta.where root_organization_id: @org['id']

    render 'admin/canvas/courses'
  end

  def canvas_accounts_sync
    @canvas_access_token = params[:canvas_token]

    org_slug = request.env['SERVER_NAME']

    @org = Organization.find_by slug: org_slug

    if @org
      @canvas_endpoint = @org[:lms_authentication_source]

      @canvas_client = Canvas::API.new(:host => @canvas_endpoint, :token => @canvas_access_token)

      if @canvas_client
        canvas_root_accounts = @canvas_client.get("/api/v1/accounts")

        canvas_root_accounts.each do |canvas_root_account|
          sync_canvas_accounts canvas_root_account, @org[:id]
        end
      else
        debugger
        false
      end
    else
      debugger
      false
    end

    redirect_to canvas_accounts_path
  end

  def canvas_courses_sync
    @canvas_access_token = params[:canvas_token]

    org_slug = request.env['SERVER_NAME']

    @org = Organization.find_by slug: org_slug

    if @org
      @canvas_endpoint = @org[:lms_authentication_source]

      @canvas_client = Canvas::API.new(:host => @canvas_endpoint, :token => @canvas_access_token)

      if @canvas_client
        canvas_accounts = OrganizationMeta.where(root_id: @org['id'], key: ['id', 'parent_id']).order :key
        debugger
        sync_canvas_courses canvas_accounts, @org[:id]
      else
        debugger
        false
      end
    else
      debugger
      false
    end

    redirect_to canvas_courses_path
  end

  def sync_canvas_accounts account, org_id = nil
    # store each piece of data into the organization meta model
    account.each do |key, value|
      meta = OrganizationMeta.find_or_initialize_by organization_id: org_id,
        key: key,
        root_id: @org[:id],
        lms_organization_id: account['id']

      meta[:value] = value.to_s

      meta.save
    end

    @child_accounts = @canvas_client.get("/api/v1/accounts/#{account['id']}/sub_accounts?per_page=50")
    @child_accounts.next_page! while @child_accounts.more?

    @child_accounts.each do |child_account|
      sync_canvas_accounts child_account
    end
  end

  def sync_canvas_courses accounts, root_org_id
    accounts.each do |account_meta|
      if account_meta.key == 'id'
        account = account_meta[:value]
      elsif account_meta.key == 'parent_id'elsif account_meta.key == 'parent_id'elsif account_meta.key == 'parent_id'
        account_parent = account_meta[:value]
      end

      if account_meta.key == 'id'
        # get all courses for the current acocunt
        canvas_courses = @canvas_client.get("/api/v1/accounts/#{account}/courses?per_page=50&with_enrollments=true")
        #canvas_courses.next_page! while @canvas_courses.more?

        # store each piece of data into the organization meta model
        canvas_courses.each do |course|
          course.each do |key, value|
            meta = DocumentMeta.find_or_initialize_by lms_course_id: course['id'],
              key: key,
              root_organization_id: @org[:id],
              lms_organization_id: account,
              lms_course_id: course['id']

            meta[:value] = value.to_s

            meta.save
          end
        end
      end
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
