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
    if canvas_client
      canvas_client.get("/api/v1/courses")
    end
  end

  def canvas_access_token
    session[:canvas_access_token]["access_token"]
  end

  def oauth_endpoint
    session[:oauth_endpoint]
  end

  def canvas_client
    if(session[:oauth_endpoint])
      lms_client = Canvas::API.new(:host => session[:oauth_endpoint], :token => canvas_access_token)
    end
  end

end
