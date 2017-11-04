require 'tempfile'
require 'zip'

class Admin::AuditorController < ApplicationController

  before_action :require_auditor_role

  def archive
    @organization = get_org
    default_term = 'SP17'
    reportJSON = nil
    report_id = ''

    reports = ReportArchive.where(organization_id: @organization.id).all

    reports.each do |r|
      if @organization.default_account_filter
        default_term = @organization.default_account_filter
      end
      if r.report_filters && r.report_filters["account_filter"] == default_term
        reportJSON = r
      end
    end

    if reportJSON
      report_id = reportJSON.id

      report = JSON.parse(reportJSON.payload)
      courses = report.map{ |x|  x['course_id'] }
      docs = Document.where(
          lms_course_id: courses
        ).where(
          organization_id: @organization.id
        ).all
    else
      docs = Document.where(organization_id: @organization.id ).all
    end

    if File.file?(get_archive_file)
      File.delete(get_archive_file)
    end

    zipfile_name = get_archive_file

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream('content.css'){ |os| os.write Rails.application.assets['application.css'].to_s }
      docs.each do |doc|

        @document = doc
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        rendered_doc = render_to_string :layout => "archive", :template => "documents/content"

        lms_identifier = @document.name.parameterize
        if @document.lms_course_id
          lms_identifier = "#{@document.lms_course_id}".parameterize
        end

        zipfile.get_output_stream("#{lms_identifier}_#{@document.id}.html") { |os| os.write rendered_doc }
      end
    end

    redirect_to '/admin/download?report='+report_id
  end

  def download
    if File.file?(get_archive_file)
      send_file get_archive_file
    elsif params

      redirect_to admin_auditor_archive_path
    end
  end

  def reportStatus
    render 'report_status', layout: '../admin/auditor/report_layout'
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

        end
      end
    end

    if File.file?(get_archive_file)
      @download_snapshot = true
    end

    render 'reports', layout: '../admin/auditor/report_layout'
  end

  def report
    @org = get_org

    rebuild = params[:rebuild]

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
        account_filter = 'FL17'
        params[:account_filter] = account_filter
      end
    end

    puts params[:account_filter]

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

      redirect_to '/admin/report'
    else
      if !@report.payload
        return redirect_to '/admin/report-status'
      end
      @report_data = JSON.parse(@report.payload)

      render 'report', layout: '../admin/auditor/report_layout'
    end
  end

  private

  def get_archive_file
    slug = get_org_slug
    if !params[:report] || params[:report] == ''
      params[:report] = 'default'
    end

    "/tmp/#{slug}_#{params[:report]}.zip"
  end
end
