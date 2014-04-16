require 'net/http'

class SyllabusesController < ApplicationController

	layout 'view'

	before_filter :lookup_syllabus, :only => [:edit, :update]
  before_filter :init_view_folder, :only => [:edit, :update, :show]
  
  def index
  	redirect_to :new
  end

  def new
  	syllabus = Syllabus.create(:name => 'Unnamed')
  	redirect_to edit_syllabus_path(:id => syllabus.edit_id)
 	end

  def show
    @syllabus = Syllabus.find_by_view_id(params[:id])

    unless @syllabus
      syllabus = Syllabus.find_by_edit_id(params[:id])

      unless syllabus
        syllabus_template = Syllabus.find_by_template_id(params[:id])
        if syllabus_template
          syllabus = syllabus_template.dup
          syllabus.reset_ids
          syllabus.save!
        end
      end

      raise ActionController::RoutingError.new('Not Found') unless syllabus
      redirect_to edit_syllabus_path(:id => syllabus.edit_id)
      return
    end

    @content = @syllabus.payload
    respond_to do |format|
      format.html {
  	    render :layout => 'view', :template => '/syllabuses/content'
      }
      format.pdf{
        html = render_to_string :layout => 'view', :template => '/syllabuses/content.html.erb'
        content = Rails.env.development? ? WickedPdf.new.pdf_from_string(html.force_encoding("UTF-8")) : html
        render :text => content, :layout => false
      }
    end
  end

  def edit
  	render :layout => 'edit', :template => '/syllabuses/content'
 	end

  def update
    generate_syllabus_pdf(@syllabus.view_id) if Rails.env.production? && params[:publish]

    canvas_course_id = params[:canvas_course_id]

    if canvas_course_id
      # publishing to canvas should not save in the syllabus model, the canvas version has been modified
      update_course_syllabus(canvas_course_id, request.raw_post) if params[:canvas] && canvas_course_id
    else
      @syllabus.payload = request.raw_post
      @syllabus.save!
    end

    respond_to do |format|
      msg = { :status => "ok", :message => "Success!" }
      format.json  {
        view_url = syllabus_url(@syllabus.view_id, :only_path => false)
        render :json => msg
      }
    end
  end

 	protected

  def view_pdf_url
    if Rails.env.production?
      "https://s3-#{APP_CONFIG['aws_region']}.amazonaws.com/#{APP_CONFIG['aws_bucket']}/hosted/#{@syllabus.view_id}.pdf"
    else
      "http://#{request.env['SERVER_NAME']}/salsas/#{@syllabus.view_id}.pdf"
    end
  end

  def view_url
    "http://#{request.env['SERVER_NAME']}/salsas/#{@syllabus.view_id}"
  end

  def template_url
    "http://#{request.env['SERVER_NAME']}/salsas/#{@syllabus.template_id}"
  end

 	def lookup_syllabus
  	@syllabus = Syllabus.find_by_edit_id(params[:id])

  	raise ActionController::RoutingError.new('Not Found') unless @syllabus
    @view_pdf_url = view_pdf_url
  	@content = @syllabus.payload
    @view_url = view_url
    @template_url = template_url
  end

  def generate_syllabus_pdf(syllabus_view_id)
    uri = URI.parse(APP_CONFIG['pdf_generator_webhook'])
    response = Net::HTTP.post_form(uri, {"url" => view_url})
  end

  def update_course_syllabus course_id, html
    lms_connection_information
    @lms_client.put("/api/v1/courses/#{course_id}", { course: { syllabus_body: html } })
    
    salsa = Syllabus.find_by edit_id: params[:id]
    
    if salsa

      if !salsa[:organization_id]
        if session[:authenticated_institution] && session[:authenticated_institution] != ''
          # find the org to bind this to
          org = Organization.find_by slug: session[:authenticated_institution]
          
          # if there is a matching org, save the salsa under that org
          if org
            salsa[:organization_id] = org[:id]
          end
        elsif @organization
          salsa[:organization_id] = @organization[:id]
        end
      end

      salsa.update(lms_published_at: DateTime.now, lms_course_id: course_id)
    end
  end
end
