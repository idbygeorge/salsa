class OrganizationsController < ApplicationController
  before_filter :require_admin_password
  before_filter :get_organizations, only: [:index, :new, :edit, :show]
  layout 'admin'
  def index
    get_documents
  end

  def new
    @organization = Organization.new
  end

  def documents
    if params[:document_ids]
      if params[:organization][:id] != ''
        org_id = params[:organization][:id]
      else
        org_id = nil
      end

      Document.update_all(["organization_id=?", org_id], :id => params[:document_ids])
    end

    redirect_to organizations_path
  end

  def show
    get_documents params[:slug]
  end

  def edit
    get_documents params[:slug]
  end

  # commit actions
  def create
    Organization.create organization_params

    redirect_to organizations_path
  end

  def update
    @organization = Organization.find_by slug:params[:slug]
    @organization.update organization_params

    redirect_to organization_path(slug: @organization[:slug])
  end

  def delete
  end

  private

  def get_documents org=params[:slug], page=params[:page], per=25, key=params[:key]
    if key == 'abandoned'
      operation = '=';
    else
      operation = '!='
    end

    if org
      @organization = Organization.find_by slug:org
      documents = Document.where("documents.organization_id=? AND documents.updated_at #{operation} documents.created_at", @organization[:id])
    else
      documents = Document.where("documents.organization_id IS NULL AND documents.updated_at #{operation} documents.created_at")
    end

    @documents = documents.order(updated_at: :desc, created_at: :desc).page(page).per(per)
  end

  def get_organizations
    @organizations = Organization.all.order(:lft, :rgt, :name)
  end

  def organization_params
    params.require(:organization).permit(:name, :slug, :parent_id, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key, :lms_info_slug)
  end
end
