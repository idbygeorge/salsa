class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def init_view_folder
    # establish the default view folder
    @view_folder = "instances/default"

    # find the matching organizaiton based on the request and being a top-level organization
    @organization = Organization.find_by slug: request.env['SERVER_NAME'], parent_id: nil

    # if a matching org was found, check if there is a custom view folder set up for it
    if @organization
      # only update the view folder if the institution folder exists
      if File.directory?("app/views/instances/custom/#{@organization.slug}")
        @view_folder = "instances/custom/#{@organization.slug}"
      end
    end
  end
end
