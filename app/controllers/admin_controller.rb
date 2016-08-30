class AdminController < ApplicationController
  before_filter :require_admin_password, except: [:canvas,:login,:logout]
  before_filter :require_audit_role, only: [:canvas]
  before_filter :get_organizations, only: [:search,:canvas_accounts,:canvas_courses]

  def login
  	@organization = find_org_by_path params[:slug]

  	if @organization and @organization[:lms_authentication_source]
  		redirect_to oauth2_login_path
	  else
  		render action: :login, layout: false
  	end
  end

  def require_audit_role
    unless has_role 'auditor' == true
      redirect_to admin_login_path
    end
  end

  def canvas
    rebuild = params[:rebuild]
    flush = params[:flush]

    @stale_difference = 5
    stale_limit = Time.now - @stale_difference.minutes

    @report_stale = nil

    #start by saving the report (add check to see if there is a report)
    @org = get_org
    @report = ReportArchive.where(organization_id: @org.id).first_or_create

    if stale_limit > @report.updated_at
      @report_stale = true
    end

    if @report.generating_at && flush && stale_limit > @report.generating_at
      @report.generating_at = nil
      @report.save!

      redirect_to '/admin/canvas'
      return
    end

    if !@report.payload || rebuild
      @report_check = ReportArchive.where('generating_at IS NOT NULL').first

      # if a report is being generated already on this server, don't proceed
      if @report_check
        return render 'canvas_stale', layout: '../admin/report_layout'
      end

      @report.generating_at = Time.now
      @report.save!

      # get the report data (slow process... only should run one at a time)
      @report_data = get_document_meta

      #store it
      @report.generating_at = nil
      @report.payload = @report_data.to_json
      @report.save!

      redirect_to '/admin/canvas'
    else
      @report_data = JSON.parse(@report.payload)

      render 'canvas', layout: '../admin/report_layout'
    end
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

  def get_org_slug
    request.env['SERVER_NAME']
  end

  def get_org
    Organization.find_by slug: get_org_slug
  end

  def get_document_meta
    org_slug = request.env['SERVER_NAME']
    @org = Organization.find_by slug: org_slug

    start_filter = ''

    if params[:start]
      start = params[:start] = params[:start].gsub(/[^\d-]/, '')
      if start != ''
        start_filter = "AND (start.value IS NULL OR CAST(start.value AS DATE) >= '#{start}')"
      end
    end

    query_string =
    <<-SQL.gsub(/^ {4}/, '')
      SELECT DISTINCT a.lms_course_id as course_id,
        a.value as account_id,
        acn.value as account,
        p.value as parent_id,
        a.document_id as document_id,
        n.value as name,
        cc.value as course_code,
        et.value as enrollment_term_id,
        sis.value as sis_course_id,
        start.value as start_at,
        p.value as parent_id,
        pn.value as parent_account_name,
        end_date.value as end_at,
        ws.value as workflow_state,
        d.edit_id as edit_id,
        d.view_id as view_id,
        d.lms_published_at as published_at


      -- prefilter the account id and course id meta information so joins will be faster (maybe...?)
      FROM document_meta as a


      -- join the name meta information
      LEFT JOIN
        document_meta as n ON (
          a.lms_course_id = n.lms_course_id
          AND a.root_organization_id = n.root_organization_id
          AND n.key = 'name'
        )

      -- join the account name
      LEFT JOIN
        organization_meta as acn ON (
          a.value = acn.lms_organization_id
          AND a.root_organization_id = acn.root_id
          AND acn.key = 'name'
        )

      -- join the account parent id
      LEFT JOIN
        organization_meta as p ON (
          acn.lms_organization_id = p.lms_organization_id
          AND acn.root_id = p.root_id
          AND p.key = 'parent_account_id'
        )

        -- join the account parent id
      LEFT JOIN
        organization_meta as pn ON (
          p.value = pn.lms_organization_id
          AND acn.root_id = pn.root_id
          AND pn.key = 'name'
        )

      -- join the course code meta infromation
      LEFT JOIN
        document_meta as cc ON (
          a.lms_course_id = cc.lms_course_id
          AND a.root_organization_id = cc.root_organization_id
          AND cc.key = 'course_code'
        )

      -- join the enrollment term meta information
      LEFT JOIN
        document_meta as et ON (
          a.lms_course_id = et.lms_course_id
          AND a.root_organization_id = et.root_organization_id
          AND et.key = 'enrollment_term_id'
          -- whitelist for enrollment term id
          -- TODO: (move this to a filter option...)

        )

      -- join the sis course id meta information
      LEFT JOIN
        document_meta as sis ON (
          a.lms_course_id = sis.lms_course_id
          AND a.root_organization_id = sis.root_organization_id
          AND sis.key = 'sis_course_id'
        )

      -- join the start date meta information
      LEFT JOIN
        document_meta as start ON (
          a.lms_course_id = start.lms_course_id
          AND a.root_organization_id = start.root_organization_id
          AND start.key = 'start_at'
          #{start_filter}
        )

      -- join the end_date date meta information
      LEFT JOIN
        document_meta as end_date ON (
          a.lms_course_id = end_date.lms_course_id
          AND a.root_organization_id = end_date.root_organization_id
          AND end_date.key = 'end_at'
        )

      -- join the workflow state meta information
      LEFT JOIN
        document_meta as ws ON (
          a.lms_course_id = ws.lms_course_id
          AND a.root_organization_id = ws.root_organization_id
          AND ws.key = 'workflow_state'
        )

      -- join the workflow state meta information
      LEFT JOIN
        documents as d ON (
          a.lms_course_id = d.lms_course_id
          --TODO: docuemnts need root organization tracked to make this faster
          AND d.organization_id IN (#{@org[:id]})
        )

      WHERE
        a.root_organization_id = #{@org[:id].to_s}
        AND a.key = 'account_id'
        AND n.value LIKE '%FA16%'

      ORDER BY pn.value, acn.value, n.value, a.lms_course_id
    SQL

    DocumentMeta.find_by_sql query_string
  end

  def canvas_courses
    @document_meta = get_document_meta

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

    CanvasHelper.courses_sync org_slug, @canvas_access_token

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
    session[:admin_authorized] = false

    redirect_to root_path;
  end

  def search page=params[:page], per=25

    @documents = Document.where("organization_id IN (#{@organizations.pluck(:id).join(',')}) AND (lms_course_id = '#{params[:q]}' OR name LIKE '%#{params[:q]}%' OR edit_id LIKE '#{params[:q]}%' OR view_id LIKE '#{params[:q]}%' OR template_id LIKE '#{params[:q]}%' OR payload LIKE '%#{params[:q]}%')").page(page).per(per)
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
