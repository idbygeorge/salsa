require 'tempfile'
require 'zip'

class Admin::AuditorController < ApplicationController

  before_action :require_auditor_role

  def download
    zipfile_path = ReportHelper.zipfile_path(get_org_slug, params[:report])
    if File.file?(zipfile_path)
      send_file (zipfile_path)
    end
  end

  def reportStatus
    render 'report_status', layout: '../admin/auditor/report_layout'
  end

  def archive_report
    report = ReportArchive.where(id: params[:report]).first
    report.is_archived = true
    report.save
    return redirect_to '/admin/reports'
  end

  def restore_report
    report = ReportArchive.where(id: params[:report]).first
    report.is_archived = false
    report.save
    return redirect_to '/admin/reports?show_archived=true'
  end

  def reports
    @org = get_org
    if params[:show_archived]
      @reports = ReportArchive.where(organization_id: @org.id, is_archived: true).order(updated_at: :desc ).all
    else
      @reports = ReportArchive.where(organization_id: @org.id, is_archived: false).order(updated_at: :desc ).all
    end
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

    render 'reports', layout: '../admin/auditor/report_layout'
  end

  def report
    @org = get_org
    params_hash = params.permit(:account_filter, :controller, :action).to_hash
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
        # jump 2 weeks ahead to allow staff to review things for upcoming semester
        date = Date.today + 2.weeks
        semester = ['SP','SU','FL'][((date.month - 1) / 4)]
        account_filter = "#{semester}#{date.strftime("%y")}"
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
      @queued = ReportHelper.generate_report_as_job @org.id, account_filter, params_hash

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

end
