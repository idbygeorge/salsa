class OrganizationsController < AdminController
  before_filter :get_organizations, only: [:index, :new, :edit, :show]
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
    @organization = Organization.create organization_params

    redirect_to organization_path(slug: full_org_path(@organization))
  end

  def update
    @organization = find_org_by_path params[:slug]
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

      documents = Document.where("documents.organization_id=? AND documents.updated_at #{operation} documents.created_at", @organization[:id])
    else
      documents = Document.where("documents.organization_id IS NULL AND documents.updated_at #{operation} documents.created_at")
    end

    @documents = documents.order(updated_at: :desc, created_at: :desc).page(page).per(per)
  end

  def organization_params
    params.require(:organization).permit(:name, :slug, :parent_id, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key, :lms_info_slug, :home_page_redirect)
  end
end
