require 'tempfile'
require 'zip'

module ReportHelper
  def self.generate_report_as_job (org_id, account_filter, params)
    @reports = ReportArchive.where(organization_id: org_id).all
    @report = nil;
    @reports.each do |report|
      if report.report_filters && report.report_filters == params
        @report = report
      end
    end
    if !@report
      @report = ReportArchive.create({organization_id: org_id, report_filters: params})
    end
    @report.generating_at = Time.now
    @report.save!(touch:false)
    ReportGenerator.enqueue(org_id, account_filter, params, @report.id)
  end

  def self.generate_report (org_slug, account_filter, params, report_id)
    @org = Organization.find_by slug: org_slug
    @report = ReportArchive.where(id: report_id).first

    # get the report data (slow process... only should run one at a time)
    puts 'Getting Document Meta'
    @report_data = self.get_document_meta org_slug, account_filter, params
    puts 'Retrieved Document Meta'

    #store it
    @report.generating_at = nil
    @report.payload = @report_data.to_json
    @report.save!

    self.archive org_slug, report_id, @report_data
  end

  def self.archive (org_slug, report_id, report_data)
    report = ReportArchive.find_by id: report_id
    @organization = Organization.find_by slug: org_slug
    docs = Document.where(organization_id: @organization.id, id: report_data.map(&:document_id)).where('updated_at != created_at').all

    zipfile_name = "/tmp/#{org_slug}_#{report_id}.zip"
    if File.exist?(zipfile_name)
      File.delete(zipfile_name)
    end
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream('content.css'){ |os| os.write CompassRails.sprockets.find_asset(logical_file_path).to_s }
      document_metas = {}
      docs.each do |doc|
        @document = doc
        lms_identifier = @document.name.gsub(/[^A-Za-z0-9]+/, '_')
        if @document.lms_course_id
          lms_identifier = "#{@document.lms_course_id}".gsub(/[^A-Za-z0-9]+/, '_')
        end
        if @organization.track_meta_info_from_document
          dm = "#{DocumentMeta.where("key LIKE :prefix AND document_id IN (:document_id)", prefix: "salsa_%", document_id: doc.id).select(:key, :value).to_json(:except => :id)}"
          document_metas["lms_course-#{@document.lms_course_id}"] = JSON.parse(dm)
          zipfile.get_output_stream("#{lms_identifier}_#{@document.id}_document_meta.json"){ |os| os.write JSON.pretty_generate(JSON.parse(dm))   }
        end
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        #rendered_doc = render_to_string :layout => "archive", :template => "documents/content"
        rendered_doc = ApplicationController.new.render_to_string(layout: 'archive',partial: 'documents/content', locals: {doc: @document, organization: @organization})

        zipfile.get_output_stream("#{lms_identifier}_#{@document.id}.html") { |os| os.write rendered_doc }
      end
      if @organization.track_meta_info_from_document
        zipfile.get_output_stream("document_meta.json"){ |os| os.write document_metas.to_json  }
      end
    end
  end

  def self.get_document_meta org_slug, account_filter, params

    org = Organization.find_by slug: org_slug

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
        d.id as document_id,
        n.value as name,
        cc.value as course_code,
        et.value as enrollment_term_id,
        sis.value as sis_course_id,
        start.value as start_at,
        p.value as parent_id,
        pn.value as parent_account_name,
        end_date.value as end_at,
        ws.value as workflow_state,
        ts.value as total_students,
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

      -- join the total_students meta information
      LEFT JOIN
        document_meta as ts ON (
          a.lms_course_id = ts.lms_course_id
          AND a.root_organization_id = ts.root_organization_id
          AND ts.key = 'total_students'
          AND ts.value != '0'
        )

      -- join the SALSA document
      LEFT JOIN
        documents as d ON (
          a.lms_course_id = d.lms_course_id
          --TODO: docuemnts need root organization tracked to make this faster
          AND d.organization_id IN (#{org[:id]})
        )

      WHERE
        a.root_organization_id = #{org[:id].to_s}
        AND a.key = 'account_id'
        AND n.value LIKE '%#{account_filter}%'

      ORDER BY pn.value, acn.value, n.value, a.lms_course_id
    SQL

    DocumentMeta.find_by_sql query_string
  end
end
