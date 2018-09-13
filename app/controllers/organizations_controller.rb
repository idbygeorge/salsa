class OrganizationsController < AdminController
  before_action :require_admin_permissions, only: [:new, :create, :destroy]
  before_action :require_organization_admin_permissions, except: [:new, :create, :destroy, :show, :index]
  before_action :require_designer_permissions, only: [
      :show,
      :index
  ]
  before_action :get_organizations, only: [:index, :new, :edit, :show, :start_workflow_form]
  layout 'admin'
  def index
    get_documents
    @roots = @organizations.roots

    if @roots.count == 1
      redirect_to organization_path(slug: full_org_path(@roots[0]))
    end
  end

  def new
    @export_types = Organization.export_types
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

    @workflow_steps = WorkflowStep.where(organization_id: @organization.organization_ids+[@organization.id])
    @organization.default_account_filter = '{"account_filter":""}' unless @organization.default_account_filter
    @organization.default_account_filter = '{"account_filter":""}' if @organization.default_account_filter == ''

    @organization.default_account_filter = @organization.default_account_filter.to_json if @organization.default_account_filter.class == Hash
  end

  # commit actions
  def create
    @export_types = Organization.export_types
    @organization = Organization.create organization_params

    redirect_to organization_path(slug: full_org_path(@organization))
  end

  def update
    @export_types = Organization.export_types
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

  def start_workflow_form
    @organization = @organizations.all.select{ |o| o.full_slug == params[:slug] }.first
    @workflow_steps = WorkflowStep.where(organization_id: @organization.organization_ids+[@organization.id], step_type: "start_step")
    user_ids = @organization.user_assignments.map(&:user_id)
    @users = User.find_by(id: user_ids)
    @periods = Period.where(organization_id: @organization.organization_ids+[@organization.id])
  end

  def start_workflow
    params.require("Start Workflow").permit(:document_name,:starting_workflow_step_id,:period_id,:start_for_sub_organizations)
    start_workflow_params = params["Start Workflow"]
    if start_workflow_params[:period_id] == "" || start_workflow_params[:starting_workflow_step_id] == "" || start_workflow_params[:document_name] == ""
      flash[:error] = "all fields must be filled"
      return redirect_back(fallback_location: start_workflow_form_path)
    end
    organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    if start_workflow_params[:start_for_sub_organizations]
      organizations = organization.descendants + [organization]
    else
      organizations = [organization]
    end
    counter = 0
    organizations.each do |org|
      user_ids = org.user_assignments.where(role: ["supervisor","staff"]).map(&:user_id)
      users = User.where(id: user_ids, archived: false)
      users.each do |user|
        next if user.documents.map(&:period_id).include?(start_workflow_params[:period_id].to_i)
        document = Document.create(workflow_step_id: start_workflow_params[:starting_workflow_step_id].to_i, organization_id: org.id, period_id: start_workflow_params[:period_id].to_i, user_id: user.id)
        document.update(name: start_workflow_params[:document_name] )
        WorkflowMailer.welcome_email(document, user, org, document.workflow_step.slug,component_allowed_liquid_variables(document.workflow_step.slug, user, org, document )).deliver_later
        counter +=1
      end
    end

    flash[:notice] = "successfully started workflow for #{counter} users for the #{Period.find(start_workflow_params[:period_id].to_i).name} period"
    return redirect_to start_workflow_form_path
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
        params.require(:organization).permit(:name, :export_type, :slug, :enable_workflows, :inherit_workflows_from_parents, :parent_id, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key, :lms_info_slug, :home_page_redirect, :skip_lms_publish, :enable_anonymous_actions, :track_meta_info_from_document, :disable_document_view, :force_https, :enable_workflow_report, default_account_filter: [:account_filter])
    elsif has_role 'organization_admin'
        params.require(:organization).permit(:name, :export_type, :enable_workflows, :lms_authentication_source, :lms_authentication_id, :lms_authentication_key, :lms_info_slug, :home_page_redirect, :skip_lms_publish, :enable_anonymous_actions, :track_meta_info_from_document, :force_https)
    end
  end
end
