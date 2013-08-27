require 'net/http'

class SyllabusesController < ApplicationController

	layout 'view'

	before_filter :lookup_syllabus, :only => [:edit, :update]

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
    generate_syllabus_pdf(@syllabus.view_id) if Rails.env.production?
    respond_to do |format|
      msg = { :status => "ok", :message => "Success!", :html => "<b>...</b>" }
      format.json  { 
        @syllabus.payload = request.raw_post
        @syllabus.save!
        view_url = syllabus_url(@syllabus.view_id, :only_path => false)
        render :json => msg 
      }
    end
  end

 	protected

 	def lookup_syllabus
  	@syllabus = Syllabus.find_by_edit_id(params[:id])
  	raise ActionController::RoutingError.new('Not Found') unless @syllabus 
  	@content = @syllabus.payload
    if Rails.env.production?
      @view_pdf_url = "https://s3-#{APP_CONFIG['aws_region']}.amazonaws.com/#{APP_CONFIG['aws_bucket']}/syllabuses/#{@syllabus.view_id}.pdf"
    else
      @view_pdf_url = "#{APP_CONFIG['domain']}/syllabuses/#{@syllabus.view_id}.pdf"
    end
    @view_url = "#{APP_CONFIG['domain']}/syllabuses/#{@syllabus.view_id}"
  end

  def generate_syllabus_pdf(syllabus_view_id)
    syllabus_url = "#{APP_CONFIG['domain']}/syllabuses/#{syllabus_view_id}"
    uri = URI.parse(APP_CONFIG['pdf_generator_webhook'])
    response = Net::HTTP.post_form(uri, {"url" => syllabus_url})
  end

end
