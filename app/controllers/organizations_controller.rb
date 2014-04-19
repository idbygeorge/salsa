class OrganizationsController < ApplicationController
  before_filter :require_admin_password
  before_filter :get_organizations, only: [:index, :new, :edit, :show]

  def index
    get_salsas
  end

  def new
    @organization = Organization.new
  end

  def documents
    if params[:salsa_ids]
      if params[:organization][:id] != ''
        org_id = params[:organization][:id]
      else
        org_id = nil
      end

      Syllabus.update_all(["organization_id=?", org_id], :id => params[:salsa_ids])
    end

    redirect_to organizations_path
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
    # if there is no admin password set up for the server and we are in the development
    # or test environment, bypass the securtiy check
    if !APP_CONFIG['admin_password'] && (Rails.env.development? || Rails.env.test?)
      session[:admin_authorized] = true
    elsif params[:admin_password] && params[:admin_password] != ''
      session[:admin_authorized] = params[:admin_password] == APP_CONFIG['admin_password']
    end

    if session[:admin_authorized] != true
      throw "Unauthroized"
    end
  end

  def get_salsas org=params[:id], page=params[:page], per=25
    if org
      salsas = Syllabus.where organization_id: org
      @organization = Organization.find_by id:org
    else 
      salsas = Syllabus.where organization_id: nil
    end

    @salsas = salsas.order(updated_at: :desc, created_at: :desc).page(page).per(per)
  end

  def get_organizations
    @organizations = Organization.all.order(:depth, :name)
  end

  def organization_params
    params.require(:organization).permit(:name, :slug, :parent_id, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key)
  end
end
