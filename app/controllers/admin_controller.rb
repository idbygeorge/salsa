require 'tempfile'
require 'zip'

class AdminController < ApplicationController
  before_action :require_admin_permissions, only: [:search]
  before_action :require_organization_admin_permissions, except: [:canvas,:login,:logout,:authenticate]
  before_action :require_audit_role, only: [:canvas]
  before_action :get_organizations, only: [:search,:canvas_accounts,:canvas_courses]

  def login
  	@organization = find_org_by_path params[:slug]

  	if @organization and @organization[:lms_authentication_source] != ""
  		redirect_to oauth2_login_path
	  else
  		render action: :login, layout: false
  	end
  end

  def authenticate
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

  def archive
    @organization = get_org
    default_term = 'SP17'
    reportJSON = nil

    if File.file?('/tmp/report_archive.zip')
      File.delete('/tmp/report_archive.zip')
    end
    reports = ReportArchive.where(organization_id: @organization.id).all
    reports.each do |r|
      if @organization.default_account_filter
        default_term = @organization.default_account_filter
      end
      if r.report_filters && r.report_filters["account_filter"] == default_term
      reportJSON = r
      end
    end
    report = JSON.parse(reportJSON.payload)
    courses = report.map{ |x|  x['course_id'] }
    docs = Document.where(lms_course_id: courses )
    docs = docs.where(organization_id: @organization.id )



    zipfile_name = "/tmp/report_archive.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream('content.css'){ |os| os.write Rails.application.assets['application.css'].to_s }
      docs.each do |doc|

        @document = doc
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        rendered_doc = render_to_string :layout => "archive", :template => "documents/content"
        zipfile.get_output_stream("#{@document.id}.html") { |os| os.write rendered_doc }
      end
    end

    redirect_to '/admin/reports'
  end

  def download
    send_file '/tmp/report_archive.zip'

  end

  def reportStatus
    render 'report_status', layout: '../admin/report_layout'
  end

  def reports
    @org = get_org
    @reports = ReportArchive.where(organization_id: @org.id).order(updated_at: :desc ).all
    @default_report = nil
    @reports.each do |report|
      if report.payload
        if @org.default_account_filter
          if report.report_filters && report.report_filters["account_filter"] == @org.default_account_filter
            @default_report = true
          end
        else
          if report.report_filters && report.report_filters["account_filter"] == 'FL16'
            @default_report = true
          end
        end
      end
    end

    if File.file?('/tmp/report_archive.zip')
      @download_snapshot = true
    end

    render 'reports', layout: '../admin/report_layout'
  end

  def canvas
    @org = get_org

    rebuild = params[:rebuild]
    flush = params[:flush]

    #Remove unneeded params
    params.delete :authenticity_token
    params.delete :utf8
    params.delete :commit
    params.delete :rebuild

    if params[:account_filter] && params[:account_filter] != ""
      account_filter = params[:account_filter]
    else
      if @org.default_account_filter
        account_filter = @org.default_account_filter
        params[:account_filter] = account_filter
      else
        account_filter = 'FL16'
        params[:account_filter] = account_filter
      end
    end

    if params[:report]
      @report = ReportArchive.where(id: params[:report]).first
      params.delete :report
    else
      #start by saving the report (add check to see if there is a report)
      @reports = ReportArchive.where(organization_id: @org.id).all

      if !@reports.empty?
        if @reports.count == 1
          @report = @reports.first;
        else
          return redirect_to '/admin/reports'
        end
      end
    end

      if !@report || rebuild

        jobs = Que.execute("select run_at, job_id, error_count, last_error, queue, args from que_jobs where job_class = 'ReportGenerator'")
        args = [ @org.id, account_filter, params ]
        jobs.each do |job|
          if job['args'] == args
            return redirect_to '/admin/report-status'
          end
        end
        @queued = ReportHelper.generate_report_as_job @org.id, account_filter, params

        redirect_to '/admin/canvas'
      else
        if !@report.payload
          return redirect_to '/admin/report-status'
        end
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
    ReportHelper.get_document_meta org_slug, 'FL16', params
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
    session[:admin_authorized] = false
    session[:authenticated_user] = nil

    redirect_to root_path;
  end

  def search page=params[:page], per=25
    search_document_text = ''

    search_document_text = "OR payload LIKE '%#{params[:q]}%'" if params[:search_document_text]

    @documents = Document.where("organization_id IN (#{@organizations.pluck(:id).join(',')}) AND (lms_course_id = '#{params[:q]}' OR name LIKE '%#{params[:q]}%' OR edit_id LIKE '#{params[:q]}%' OR view_id LIKE '#{params[:q]}%' OR template_id LIKE '#{params[:q]}%' #{search_document_text})").page(page).per(per)
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
