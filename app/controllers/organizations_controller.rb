class OrganizationsController < ApplicationController
  before_filter :require_admin_password
  before_filter :get_organizations, only: [:index, :new, :edit, :show]

  def index
    get_salsas
  end

  def new
    @organization = Organization.new
  end

  def edit
  end

  def show
    get_salsas params[:id]
  end

  # commit actions
  def create
    Organization.create organization_params

    redirect_to organizations_path
  end

  def update
    Organization.update params[:id], organization_params

    redirect_to organizations_path(id: params[:id])
  end

  def delete
  end

  private

  def require_admin_password
    if params[:admin_password] && params[:admin_password] != ''
      session[:admin_authorized] = params[:admin_password] == APP_CONFIG['admin_password']
    end

    if session[:admin_authorized] != true
      throw "Unauthroized"
    end
  end

  def get_salsas org=params[:id]
    if org
      @salsas = Syllabus.where organization_id: org
      @organization = Organization.find_by id:org
    else 
      @salsas = Syllabus.all
    end
  end

  def get_organizations
    @organizations = Organization.where.not(id: params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :slug, :parent_id, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key)
  end
end
