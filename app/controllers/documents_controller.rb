require 'net/http'

class DocumentsController < ApplicationController

  layout 'view'

  before_filter :lms_connection_information, :only => [:edit, :course, :course_list]
  before_filter :lookup_document, :only => [:edit, :update]
  before_filter :init_view_folder, :only => [:new, :edit, :update, :show, :course]

  def index
    redirect_to :new
  end

  def new
    @document = Document.new(name: 'Unnamed')

    # if an lms course ID is specified, capture it with the document
    @document[:lms_course_id] = params[:lms_course_id]

    verify_org

    @document.save!

    if params[:sub_organization_slugs]
      redirect_to edit_sub_org_document_path(id: @document.edit_id, sub_organization_slugs: params[:sub_organization_slugs])
    else
      redirect_to edit_document_path(id: @document.edit_id)
    end
  end

  def show
    @document = Document.find_by_view_id(params[:id])

    unless @document
      document = Document.find_by_edit_id(params[:id])

      unless document
        document_template = Document.find_by_template_id(params[:id])
        if document_template
          document = document_template.dup
          document.reset_ids
          document.save!
        end
      end

      raise ActionController::RoutingError.new('Not Found') unless document
      redirect_to edit_document_path(:id => document.edit_id)
      return
    end

    @calendar_only = params[:calendar_only] ? true : false

    @action = 'show'

    respond_to do |format|
      format.html {
        render :layout => 'view', :template => '/documents/content'
      }
      format.pdf{
        html = render_to_string :layout => 'view', :template => '/documents/content.html.erb'
        content = Rails.env.development? ? WickedPdf.new.pdf_from_string(html.force_encoding("UTF-8")) : html
        render :text => content, :layout => false
      }
    end
  end

  def edit

    @document.revert_to params[:version].to_i if params[:version]
    verify_org

    render :layout => 'edit', :template => '/documents/content'
  end

  def course
    begin
      @lms_course = @lms_client.get("/api/v1/courses/#{params[:lms_course_id]}", { include: 'syllabus_body' }) if @lms_client.token
    rescue
      raise ActionController::RoutingError.new('Not Authorized')
    end

    if @lms_course
      @document = Document.find_by lms_course_id: params[:lms_course_id], organization: @organization

      # flag to see if there is a match on the token id
      token_matches = false

      if params[:document_token]
        # check if the supplied token token_matches the document view_id
        if @document && @document[:view_id] == params[:document_token]
          token_matches = true
        end
      else
        # no token, proceed as normal
        token_matches = true
      end

      unless @document && token_matches
        # if they have a document token (read only token for now) then see if it exists
        if params[:document_token]
          @document = Document.find_by view_id: params[:document_token], organization: @organization

          if @document
            # we need to setup the course and associate it with canvas
            if params[:canvas]
              @document = Document.new(name: @lms_course['name'], lms_course_id: params[:lms_course_id], organization: @organization, payload: @document[:payload])
              @document.save!

              return redirect_to lms_course_document_path(lms_course_id: params[:lms_course_id])
            else
              # show options to user (make child, make new)
              @template_url = template_url

              return render :layout => 'relink', :template => '/documents/relink'
            end
          end
        end

        @document = Document.new(name: @lms_course['name'], lms_course_id: params[:lms_course_id], organization: @organization)
        @document.save!
      end

      @document.revert_to params[:version].to_i if params[:version]

      @view_pdf_url = view_pdf_url
      @view_url = view_url
      @template_url = template_url

      # backwards compatibility alias
      @syllabus = @document

      render :layout => 'edit', :template => '/documents/content'
    else
      if params[:document_token]
        redirect_to controller: 'oauth2', action: 'login', lms_course_id: params[:lms_course_id], document_token: params[:document_token]
      else
        redirect_to controller: 'oauth2', action: 'login', lms_course_id: params[:lms_course_id]
      end
    end
  end

  def course_list
    raise ActionController::RoutingError.new('Not Found') unless @lms_user

    verify_org

    if params[:page]
      @page = params[:page].to_i if params[:page]
    else
      @page = 1
    end

    @lms_courses = @lms_client.get("/api/v1/courses", per_page: 20, page: @page) if @lms_client.token

    render :layout => 'organizations', :template => '/documents/from_lms'
  end

  def update
    canvas_course_id = params[:canvas_course_id]

    verify_org

    if canvas_course_id
      # publishing to canvas should not save in the Document model, the canvas version has been modified
      update_course_document(canvas_course_id, request.raw_post, @organization[:lms_info_slug]) if params[:canvas] && canvas_course_id
    else
      if(params[:canvas_relink_course_id])
        #find old document in this org with this id, set to null
        old_document = Document.find_by lms_course_id: params[:canvas_relink_course_id], organization: @organization
        old_document.update(lms_published_at: nil, lms_course_id: nil)

        #set this document's canvas_course_id
        @document.lms_course_id = params[:canvas_relink_course_id]
      end

      @document.payload = request.raw_post

      @document.payload = nil if @document.payload == ''

      @document.save!
    end

    respond_to do |format|
      msg = { :status => "ok", :message => "Success!" }
      format.json  {
        view_url = document_url(@document.view_id, :only_path => false)
        render :json => msg
      }
    end
  end

  protected

  def view_pdf_url
    if Rails.env.production?
      "https://s3-#{APP_CONFIG['aws_region']}.amazonaws.com/#{APP_CONFIG['aws_bucket']}/hosted/#{@document.view_id}.pdf"
    else
      "http://#{request.env['SERVER_NAME']}#{redirect_port}/#{sub_org_slugs}SALSA/#{@document.view_id}.pdf"
    end
  end

  def view_url
    "http://#{request.env['SERVER_NAME']}#{redirect_port}/#{sub_org_slugs}SALSA/#{@document.view_id}"
  end

  def template_url
    "http://#{request.env['SERVER_NAME']}#{redirect_port}/#{sub_org_slugs}SALSA/#{@document.template_id}"
  end

  def sub_org_slugs
    params[:sub_organization_slugs] + '/' if params[:sub_organization_slugs]
  end

  def lookup_document
    @document = Document.find_by_edit_id(params[:id])

    raise ActionController::RoutingError.new('Not Found') unless @document
    @view_pdf_url = view_pdf_url
    @view_url = view_url
    @template_url = template_url

    # use the component that was used when this document was created
    if @document.component_version
      @document.component.revert_to @document.component_version
    end

    # backwards compatibility alias
    @syllabus = @document
  end

  def update_course_document course_id, html, lms_info_slug
    lms_connection_information

    @lms_client.put("/api/v1/courses/#{course_id}", { course: { syllabus_body: html } })

    if(lms_info_slug)
      @lms_client.put("/api/v1/courses/#{course_id}/#{lms_info_slug}", { wiki_page: { body: "<p><a id='edit-gui-salsa' href='#{ document_url(@document[:edit_id]) }' target='_blank'>Edit your <abbr title='Styled and Accessible Learning Service Agreement'>SALSA</abbr></a></p>", hide_from_students: true } })
    end

    if @document
      @document.update(lms_published_at: DateTime.now, lms_course_id: course_id)
    end
  end

  def verify_org
    document_slug = request.env['SERVER_NAME']
    @salsa_link = document_path(@document[:edit_id])

    if params[:sub_organization_slugs]
      document_slug += '/' + params[:sub_organization_slugs]

      if @document[:edit_id]
        @salsa_link = sub_org_document_path @document[:edit_id], sub_organization_slugs: params[:sub_organization_slugs]
      else
        @salsa_link = new_sub_org_document_path sub_organization_slugs: params[:sub_organization_slugs]
      end
    end

    if @organization && @organization[:id]
      org = @organization
    else
      if session[:authenticated_institution] && session[:authenticated_institution] != '' && session[:authenticated_institution] != document_slug
        document_slug = session[:authenticated_institution] + '.' + document_slug
      end

      # find the org to bind this to
      org = Organization.find_by slug: document_slug
    end

    # if there is no org yet, make one
    org = Organization.create name: document_slug + ' (unverified)', slug: document_slug unless org
    @document[:organization_id] = org[:id] if @document

    @organization = org
  end
end
