require 'net/http'

class DocumentsController < ApplicationController

	layout 'view'

	before_filter :lookup_document, :only => [:edit, :update]
  before_filter :init_view_folder, :only => [:new, :edit, :update, :show]
  
  def index
  	redirect_to :new
  end

  def new
    @document = Document.new(name: 'Unnamed')

    verify_org

    @document.save!

  	redirect_to edit_document_path(:id => @document.edit_id)
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

    @content = @document.payload
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
    # capture the canvas user in the session
    lms_connection_information
    @lms_user = @lms_client.get("/api/v1/users/self/profile") if @lms_client
    
  	render :layout => 'edit', :template => '/documents/content'
 	end

  def update
    generate_document_pdf(@document.view_id) if Rails.env.production? && params[:publish]

    canvas_course_id = params[:canvas_course_id]

    verify_org

    if canvas_course_id
      # publishing to canvas should not save in the Document model, the canvas version has been modified
      update_course_document(canvas_course_id, request.raw_post, @organization[:lms_info_slug]) if params[:canvas] && canvas_course_id
    else
      @document.payload = request.raw_post
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
      "http://#{request.env['SERVER_NAME']}/SALSA/#{@document.view_id}.pdf"
    end
  end

  def view_url
    "http://#{request.env['SERVER_NAME']}/SALSA/#{@document.view_id}"
  end

  def template_url
    "http://#{request.env['SERVER_NAME']}/SALSA/#{@document.template_id}"
  end

 	def lookup_document
  	@document = Document.find_by_edit_id(params[:id])

  	raise ActionController::RoutingError.new('Not Found') unless @document
    @view_pdf_url = view_pdf_url
  	@content = @document.payload
    @view_url = view_url
    @template_url = template_url

    # backwards compatibility alias
    @syllabus = @document
  end

  def generate_document_pdf(document_view_id)
    uri = URI.parse(APP_CONFIG['pdf_generator_webhook'])
    response = Net::HTTP.post_form(uri, {"url" => view_url})
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

    if session[:authenticated_institution] && session[:authenticated_institution] != '' && session[:authenticated_institution] != document_slug
      document_slug = session[:authenticated_institution] + '.' + document_slug

      # find the org to bind this to
      org = Organization.find_by slug: document_slug
    elsif @organization
      org = @organization
    end

    # if there is no org yet, make one
    org = Organization.create name: document_slug + ' (unverified)', slug: document_slug unless org
    @document[:organization_id] = org[:id]
  end
end