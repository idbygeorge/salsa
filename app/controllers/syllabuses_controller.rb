class SyllabusesController < ApplicationController

	layout 'view'

	before_filter :lookup_syllabus, :only => [:view, :edit]

  def index
  	redirect_to :new
  end

  def new
  	syllabus = Syllabus.create(:name => 'Unnamed')
  	redirect_to edit_syllabus_path(:id => syllabus.edit_id)
 	end

  def show
  	render :layout => 'view', :template => '/syllabuses/content'
  end

  def edit
  	render :layout => 'edit', :template => '/syllabuses/content'
 	end

 	protected

 	def lookup_syllabus
  	@syllabus = Syllabus.find_by_edit_id(params[:id])
  	raise ActionController::RoutingError.new('Not Found') unless @syllabus 
  	@content = @syllabus.payload
  end

end
