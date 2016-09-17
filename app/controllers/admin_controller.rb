require 'tempfile'
require 'zip'

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

  def archive
    @organization = get_org

    if File.file?('/vagrant/tmp/report_archive.zip')
      File.delete('/vagrant/tmp/report_archive.zip')
    end
    reportJSON = ReportArchive.where(organization_id: @organization.id).first
    report = JSON.parse(reportJSON.payload)
    courses = report.map{ |x|  x['course_id'] }
    # byebug
    docs = Document.where(lms_course_id: courses )
    docs = docs.where(organization_id: @organization.id )



    zipfile_name = "/vagrant/tmp/report_archive.zip"

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

    redirect_to '/admin/canvas'
  end

  def download
    send_file '/vagrant/tmp/report_archive.zip'

  end


  def require_audit_role
    unless has_role 'auditor' == true
      redirect_to admin_login_path
    end
  end

  def reportStatus
    render 'report_status', layout: '../admin/report_layout'
  end

  def canvas
    rebuild = params[:rebuild]
    flush = params[:flush]

    if File.file?('/vagrant/tmp/report_archive.zip')
      @download_snapshot = true
    end

    @org = get_org

    #Remove unneeded params
    params.delete :authenticity_token
    params.delete :utf8
    params.delete :commit
    filter = params.keys.sort.map {|k| "{'#{k}':'#{params[k]}'},"}.join
    filter = filter[0, filter.length - 1]
    #start by saving the report (add check to see if there is a report)
    @report = ReportArchive.where(organization_id: 6).all
    if(@report.empty?)
      @report = ReportArchive.create([organization_id: 5, payload: ''])
    end

    if !@report.payload || rebuild

      jobs = Que.execute("select run_at, job_id, error_count, last_error, queue, args from que_jobs where job_class = 'ReportGenerator'")
      args = [ @org.id, params[:account_filter], params ]
      jobs.each do |job|
        if job['args'] == args
          return redirect_to '/admin/report-status'
        end
      end
      @queued = ReportHelper.generate_report_as_job @org.id, account_filter, params

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
