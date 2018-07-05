class OrganizationsController < AdminController
  before_action :require_admin_permissions, only: [:new, :create, :destroy]
  before_action :require_organization_admin_permissions, except: [:new, :create, :destroy, :show, :index]
  before_action :require_designer_permissions, only: [
      :show,
      :index
  ]
  before_action :get_organizations, only: [:index, :new, :edit, :show]
  layout 'admin'
  def index
    get_documents

    @roots = @organizations.roots

    if @roots.count == 1
      redirect_to organization_path(slug: full_org_path(@roots[0]))
    end
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

      Document.where(:id => params[:document_ids]).update_all(["organization_id=?", org_id])
    end

    redirect_to organizations_path
  end

  def show
    get_documents params[:slug]
  end

  def edit
    @export_types = Organization.export_types
    get_documents params[:slug]

    @organization.default_account_filter = '{"account_filter":""}' unless @organization.default_account_filter
    @organization.default_account_filter = '{"account_filter":""}' if @organization.default_account_filter == ''

    @organization.default_account_filter = @organization.default_account_filter.to_json if @organization.default_account_filter.class == Hash
  end

  # commit actions
  def create
    @organization = Organization.create organization_params

    redirect_to organization_path(slug: full_org_path(@organization))
  end

  def update
    @organization = find_org_by_path params[:slug]

    if has_role('admin') && params['organization']['default_account_filter'] != nil
      if params['organization']['default_account_filter'] != ''
        params['organization']['default_account_filter'] = JSON.parse(params['organization']['default_account_filter'])
      else
        params['organization']['default_account_filter'] = ''
      end
    end

    @organization.update organization_params

    redirect_to organization_path(slug: full_org_path(@organization))
  end

  def destroy
    @organization = find_org_by_path params[:slug]
    @organization.destroy

    redirect_to organizations_path
  end

  def import

  end

  private

  def get_documents path=params[:slug], page=params[:page], per=25, key=params[:key]
    if key == 'abandoned'
      operation = '=';
    else
      operation = '!='
    end

    if path
      @organization = find_org_by_path path
    end

    if @organization
      documents = Document.where("documents.organization_id=? AND documents.updated_at #{operation} documents.created_at", @organization[:id])
    else
      documents = Document.where("documents.organization_id IS NULL AND documents.updated_at #{operation} documents.created_at")
    end

    @documents = documents.order(updated_at: :desc, created_at: :desc).page(page).per(per)
  end

  def organization_params
    if has_role 'admin'
        params.require(:organization).permit(:name, :export_type, :slug, :parent_id, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key, :lms_info_slug, :home_page_redirect, :skip_lms_publish, :enable_anonymous_actions, :track_meta_info_from_document, default_account_filter: [:account_filter])
    elsif has_role 'organization_admin'
        params.require(:organization).permit(:name, :export_type, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key, :lms_info_slug, :home_page_redirect, :skip_lms_publish, :enable_anonymous_actions, :track_meta_info_from_document)
    end
  end
end
