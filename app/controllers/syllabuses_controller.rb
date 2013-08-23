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
  	render :layout => 'view', :template => '/syllabuses/content'
  end

  def edit
  	render :layout => 'edit', :template => '/syllabuses/content'
 	end

  def update
    respond_to do |format|
      msg = { :status => "ok", :message => "Success!", :html => "<b>...</b>" }
      format.json  { 
        @syllabus.payload = request.raw_post
        @syllabus.save!
        render :json => msg 
      }
    end
  end

 	protected

 	def lookup_syllabus
  	@syllabus = Syllabus.find_by_edit_id(params[:id])
  	raise ActionController::RoutingError.new('Not Found') unless @syllabus 
  	@content = @syllabus.payload
    @view_url = "#{APP_CONFIG['domain']}/syllabuses/#{@syllabus.view_id}"
  end

end
