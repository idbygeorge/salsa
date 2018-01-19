class AdminController < ApplicationController
  before_action :require_designer_permissions, except: [
    :landing,
    :login,
    :logout,
    :authenticate,
    :canvas_accounts,
    :canvas_courses,
    :canvas_accounts_sync,
    :canvas_courses_sync
  ]
  before_action :require_organization_admin_permissions, only: [
    :canvas_accounts,
    :canvas_courses,
    :canvas_accounts_sync,
    :canvas_courses_sync

  ]
  before_action :get_organizations, only: [
      :search,
      :canvas_accounts,
      :canvas_courses
  ]

  def landing
    if has_role 'designer'
      return redirect_to organizations_path
    elsif has_role 'auditor'
      return redirect_to admin_auditor_reports_path
    else
      return redirect_or_error
    end
  end

  def login
  	@organization = find_org_by_path params[:slug]

  	if @organization and @organization[:lms_authentication_source] != "" and @organization[:lms_authentication_source] != nil
  		redirect_to oauth2_login_path
	  else
  		render action: :login, layout: false
  	end
  end

  def authenticate

    # allow using the login form for the admin password if it is set
    if APP_CONFIG['admin_password']
        if params[:user][:email] == 'admin@' + (params[:slug] || request.env['SERVER_NAME'])
          session[:admin_authorized] = params[:user][:password] == APP_CONFIG['admin_password']

          return redirect_to admin_path
        end
    end

  	@organization = find_org_by_path params[:slug]

    unless params[:user][:email] && params[:user][:password]
        flash[:error] = 'Missing email or password'
        return render action: :login, layout: false
    end

    user = User.where(email: params[:user][:email]).first

    unless user
        flash[:error] = 'No account matches the email provided'
        return render action: :login, layout: false
    end

    unless user.password_digest# && user.activated
        flash[:error] = 'Your account is not active yet'
        return render action: :login, layout: false
    end

    unless user.authenticate(params[:user][:password])
        flash[:error] = 'Invalid email or password'
        return render action: :login, layout: false
    end

    session[:authenticated_user] = user.id

    return redirect_to admin_path
  end

  def canvas_accounts
    org_slug = request.env['SERVER_NAME']
    @org = Organization.find_by slug: org_slug

    org_meta = OrganizationMeta.where(
      root_id: @org['id'],
      key: [
        'id',
        'name',
        'parent_account_id',
        'root_account_id',
        'sis_account_id',
        'workflow_state'
      ]
    )

    @org_meta = PivotTable::Grid.new do |g|
      g.source_data = org_meta
      g.column_name = :key
      g.row_name = :lms_organization_id
    end

    @org_meta.build

    render 'admin/canvas/accounts'
  end

  def canvas_courses
    if params[:show_course_meta]
        @document_meta = get_document_meta
    end

    @queued = Que.execute("select run_at, job_id, error_count, last_error, queue from que_jobs where job_class = 'CanvasSyncCourseMeta'")
    @queued_count = @queued.count

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

    CanvasHelper.courses_sync_as_job org_slug, @canvas_access_token

    redirect_to canvas_courses_path
  end

  def sync_canvas_accounts account, org_id = nil
    # store each piece of data into the organization meta model
    account.each do |key, value|
      meta = OrganizationMeta.find_or_initialize_by organization_id: org_id,
        key: key,
        root_id: @org[:id],
        lms_organization_id: account['id'].to_s

      meta[:value] = value.to_s

      meta.save
    end

    @child_accounts = @canvas_client.get("/api/v1/accounts/#{account['id']}/sub_accounts?per_page=50")

    @child_accounts.next_page! while @child_accounts.more?

    @child_accounts.each do |child_account|
      sync_canvas_accounts child_account
    end
  end

  def logout
    reset_session

    redirect_to root_path;
  end

  def search page=params[:page], per=25
    search_document_text = ''

    search_document_text = "OR payload ~* '.*#{params[:q]}.*'" if params[:search_document_text]

    @documents = Document.where("organization_id IN (#{@organizations.pluck(:id).join(',')}) AND (lms_course_id = '#{params[:q]}' OR name ~* '.*#{params[:q]}.*' OR edit_id ~* '#{params[:q]}.*' OR view_id ~* '#{params[:q]}.*' OR template_id ~* '#{params[:q]}.*' #{search_document_text})").page(page).per(per)
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
