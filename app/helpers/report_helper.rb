require 'tempfile'
require 'zip'

module ReportHelper
  def self.generate_report_as_job (org_id, account_filter, params)
    @reports = ReportArchive.where(organization_id: org_id).all
    @report = nil;
    org = Organization.find(org_id)
    if account_filter.blank?
      account_filter = org.default_account_filter
    end
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
    @organization = Organization.find_by slug: org_slug
    @report = ReportArchive.where(id: report_id).first

    if !account_filter_blank?(account_filter) && @organization.root_org_setting("enable_workflow_report")
      docs = Document.where(workflow_step_id: WorkflowStep.where(organization_id: @organization.parents.push(@organization.id), step_type: "end_step").map(&:id), organization_id: @organization.id, period_id: Period.where(slug: account_filter)).where('updated_at != created_at').all
    elsif @organization.root_org_setting("enable_workflow_report")
      docs = Document.where(workflow_step_id: WorkflowStep.where(organization_id: @organization.parents.push(@organization.id), step_type: "end_step").map(&:id), organization_id: @organization.id).where('updated_at != created_at').all
    end
    # get the report data (slow process... only should run one at a time)
    puts 'Getting Document Meta'
    if @organization.root_org_setting("enable_workflow_report")
      @report_data = self.get_workflow_document_meta docs&.map(&:id)
    else
      @report_data = self.get_document_meta org_slug, account_filter, params
    end
    puts 'Retrieved Document Meta'

    if !account_filter_blank?(account_filter) && !@organization.root_org_setting("enable_workflow_report")
      docs = Document.where(organization_id: @organization.id, id: @report_data.map(&:document_id)).where('updated_at != created_at').all
    elsif !@organization.root_org_setting("enable_workflow_report")
      docs = Document.where(organization_id: @organization.id).where('updated_at != created_at').all
    end

    #store it
    @report.generating_at = nil
    @report.payload = @report_data.to_json
    @report.save!

    self.archive org_slug, report_id, @report_data, account_filter, docs
    puts 'Report Generated'
  end

  def self.account_filter_blank? account_filter
    result = false
    if account_filter.blank? || account_filter == {"account_filter"=>""}
      result = true
    end
    result
  end

  def self.archive (org_slug, report_id, report_data, account_filter=nil, docs)
    report = ReportArchive.find_by id: report_id
    @organization = Organization.find_by slug: org_slug

    FileUtils.rm zipfile_path(org_slug, report_id), :force => true   # never raises exception

    Zip::File.open(zipfile_path(org_slug, report_id), Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream('content.css'){ |os| os.write CompassRails.sprockets.find_asset('application.css').to_s }
      if @organization.root_org_setting("export_type")== "Program Outcomes"
        document_metas = []
      else
        document_metas = {}
      end
      docs.each do |doc|
        identifier = doc.id
        folder = nil
        folder = "#{doc.period&.slug}/" if @organization.root_org_setting("enable_workflow_report")
        identifier = doc.name.gsub(/[^A-Za-z0-9]+/, '_') if doc.name
        if doc.lms_course_id
          identifier = "#{doc.lms_course_id}".gsub(/[^A-Za-z0-9]+/, '_')
        end
        if @organization.root_org_setting("track_meta_info_from_document") && @organization.root_org_setting("export_type")== "Program Outcomes"
          program_outcomes_format(doc, document_metas)
        elsif @organization.root_org_setting("track_meta_info_from_document") && dm = "#{DocumentMeta.where("key LIKE :prefix AND document_id IN (:document_id)", prefix: "salsa_%", document_id: doc.id).select(:key, :value).to_json(:except => :id)}" != "[]"
          document_metas["lms_course-#{doc.lms_course_id}"] = JSON.parse(dm)
          zipfile.get_output_stream("#{folder}#{identifier}_#{doc.id}_document_meta.json"){ |os| os.write JSON.pretty_generate(JSON.parse(dm)) }
        end
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        #rendered_doc = render_to_string :layout => "archive", :template => "documents/content"
        rendered_doc = ApplicationController.new.render_to_string(layout: 'archive',partial: 'documents/content', locals: {doc: doc, organization: @organization, :@organization => @organization})

        zipfile.get_output_stream("#{folder}#{identifier}_#{doc.id}.html") { |os| os.write rendered_doc }
      end
      if @organization.root_org_setting("track_meta_info_from_document") && document_metas != {}
        zipfile.get_output_stream("document_meta.json"){ |os| os.write document_metas.to_json  }
      end
    end
  end

  def self.program_outcomes_format doc, document_metas
    dms = DocumentMeta.where("key LIKE :prefix AND document_id IN (:document_id)", prefix: "salsa_%", document_id: doc.id)
    dms_array = []
    dms&.each do |dm|
      salsa_hash = Hash.new
      salsa_outcome = dm.key.split("_")[1].split("-")
      if salsa_outcome.length >= 3
        if salsa_outcome.length > 3
          salsa_outcome_type = "#{salsa_outcome[1]}: " + salsa_outcome[2..-2].join(' ')
        else
          salsa_outcome_type = salsa_outcome[1]
        end
        salsa_hash[:lms_course_id] = "#{dm.lms_course_id}"
        salsa_hash[:salsa_outcome] = salsa_outcome[0]
        salsa_hash[:salsa_outcome_type] = salsa_outcome_type
        salsa_hash[:salsa_outcome_id] = salsa_outcome.last
        salsa_hash[:salsa_outcome_text] = dm.value
        salsa_hash[:key] = ""
        salsa_hash[:value] = ""
      else
        salsa_hash[:lms_course_id] = "#{dm.lms_course_id}"
        salsa_hash[:salsa_outcome] = ""
        salsa_hash[:salsa_outcome_type] = ""
        salsa_hash[:salsa_outcome_id] = ""
        salsa_hash[:salsa_outcome_text] = ""
        salsa_hash[:key] = dm.key
        salsa_hash[:value] = dm.value

      end
      document_metas.push JSON.parse(salsa_hash.to_json)
      dms_array.push JSON.parse(salsa_hash.to_json)
    end
  end

  def self.zipfile_path (org_slug, report_id)
    "#{ENV["ZIPFILE_FOLDER"]}/#{org_slug}_#{report_id}.zip"
  end

  def self.get_workflow_document_meta doc_ids
    DocumentMeta.where(document_id: doc_ids)
  end

  def self.get_document_meta org_slug, account_filter, params
    query_parameters = {}

    org = Organization.find_by slug: org_slug

    if !account_filter_blank?(account_filter)
      query_parameters[:account_filter] = "%#{account_filter}%"
      account_filter_sql = "AND n.value LIKE :account_filter AND a.key = 'account_id'"
    else
      account_filter_sql = nil
    end

    start_filter = ''
    if params[:start]
      start = params[:start] = params[:start].gsub(/[^\d-]/, '')
      if start != ''
        query_parameters[:start] = params[:start]
        start_filter = "AND (start.value IS NULL OR CAST(start.value AS DATE) >= :start)"
      end
    end

    limit_sql = nil
    if params[:page]
        query_parameters[:offset] = (params[:page] || 1).to_i
        query_parameters[:limit] = (params[:per] || 1).to_i
        limit_sql = 'offset :offset limit :limit'
    end

    query_parameters[:org_id] = org[:id]
    query_parameters[:org_id_string] = org[:id].to_s

    DocumentMeta.find_by_sql([document_meta_query_sql(account_filter_sql, limit_sql, start_filter), query_parameters])
  end

  def self.document_meta_query_sql account_filter_sql, limit_sql, start_filter
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
          AND d.organization_id IN (:org_id)
        )

      WHERE
        a.root_organization_id = :org_id_string
        #{account_filter_sql}

      ORDER BY pn.value, acn.value, n.value, a.lms_course_id

      #{limit_sql}
    SQL
  end

end
