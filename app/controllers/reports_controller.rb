class ReportsController < ApplicationController
  before_action :require_admin_permissions
  before_action :get_organizations, only: [:index, :new, :edit, :show]

  before_action :lms_connection_information, :only => [:show]

  layout 'admin'

  def index
  end

  def show
    # assuming syllabus report
    @organization = Organization.find_by slug: params[:organization_slug]

    @courses = @lms_client.get("/api/v1/accounts/") if @lms_client.token
  end
end
