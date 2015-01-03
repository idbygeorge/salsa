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
    org_slug = request.env['SERVER_NAME']
    @org = Organization.find_by slug: org_slug

query_string =
<<SQL
  SELECT DISTINCT a.course_id as 'id', account_id, name, course_code, enrollment_term_id, sis_course_id, start_at, end_at, workflow_state
  FROM (
    SELECT
      dm.value as 'account_id',
      dm.lms_course_id as 'course_id'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'account_id'
  ) as a
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'name'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'name'
  ) as n ON (a.course_id = n.course_id)
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'course_code'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'course_code'
  ) as cc ON (a.course_id = cc.course_id)
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'enrollment_term_id'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'enrollment_term_id'
  ) as et ON (a.course_id = et.course_id)
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'sis_course_id'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'sis_course_id'
  ) as sis ON (a.course_id = sis.course_id)
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'start_at'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'start_at'
  ) as start ON (a.course_id = start.course_id)
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'end_at'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'end_at'
  ) as end ON (a.course_id = end.course_id)
  LEFT JOIN (
    SELECT
      dm.lms_course_id as 'course_id',
      dm.value as 'workflow_state'
    FROM document_meta as dm
    WHERE
    root_organization_id = :root_organization_id
    AND dm.key = 'workflow_state'
  ) as ws ON (a.course_id = ws.course_id)
SQL

    @document_meta = DocumentMeta.find_by_sql query_string, { root_organization_id: @org[:id]}

    # document_meta = DocumentMeta.where(
    #   root_organization_id: @org['id'],
    #   key: [
    #     'account_id',
    #     'course_code',
    #     'end_at',
    #     'enrollment_term_id',
    #     'id',
    #     'name',
    #     'sis_course_id',
    #     'start_at',
    #     'workflow_state'
    #   ]
    # )

    # @document_meta = PivotTable::Grid.new do |g|
    #   g.source_data = document_meta
    #   g.column_name = :key
    #   g.row_name = :lms_course_id
    # end
    #
    # @document_meta.build

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
      if account_meta.key == 'id' then
        account = account_meta[:value]
      elsif account_meta.key == 'parent_id'
        account_parent = account_meta[:value]
      end

      if account_meta.key == 'id' then
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
