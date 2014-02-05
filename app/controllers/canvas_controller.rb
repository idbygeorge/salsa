class CanvasController < ApplicationController
  def list_courses
    @syllabus = Syllabus.find_by_edit_id(params[:id])
    @courses = fetch_course_list
    render json: {
        'html' => render_to_string(partial: 'list_courses.html', locals: { courses: @courses, syllabus: @syllabus })
    }
  end

  protected

  def fetch_course_list
    canvas_client.get("/api/v1/courses")
  end

  def canvas_access_token
    session[:canvas_access_token]["access_token"]
  end

  def canvas_client
    Canvas::API.new(:host => APP_CONFIG['canvas_api_endpoint'], :token => canvas_access_token)
  end
end
