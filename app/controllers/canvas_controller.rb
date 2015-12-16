class CanvasController < ApplicationController
  before_filter :init_view_folder, :only => [:list_courses]

  def list_courses
    select_course_dialog 'list_courses'
  end

  def relink_courses
    select_course_dialog 'relink_courses'
  end

  def select_course_dialog partial
    @document = Document.find_by_edit_id(params[:id])
    @courses = fetch_course_list

    # gather the course IDs from canvas result
    lms_course_ids = @courses.map{|c| c['id'].to_s }

    # find all organizations in this branch of the org tree
    org_tree = @document.organization.root.self_and_descendants.pluck :id

    # find all documents in org tree that match on the @courses.id
    linked_courses_salsa = Document.where organization_id: org_tree, lms_course_id: lms_course_ids

    if linked_courses_salsa.size
      @linked_courses = @courses.select { |c| linked_courses_salsa.find_by(lms_course_id: c['id'].to_s) != nil }
      @unlinked_courses = @courses.select { |c| linked_courses_salsa.find_by(lms_course_id: c['id'].to_s) == nil }

      courses = Hash[@courses.map { |c| [c['id'], c] }]

      render json: {
        'html' => render_to_string(
          partial: partial,
          locals: {
            courses: courses,
            linked_courses: @linked_courses,
            unlinked_courses: @unlinked_courses,
            document: @document
          }
        )
      }
    end
  end

  protected

  def fetch_course_list
    if canvas_client
      canvas_client.get("/api/v1/courses?per_page=50", { include: 'syllabus_body' })
    end
  end

  def canvas_access_token
    session[:canvas_access_token]["access_token"]
  end

  def oauth_endpoint
    session[:oauth_endpoint]
  end

  def canvas_client
    if(session[:oauth_endpoint] && session[:oauth_endpoint] != '')
      lms_client = Canvas::API.new(:host => session[:oauth_endpoint], :token => canvas_access_token)
    end
  end

end
