class WorkflowDocumentsController < AdminDocumentsBaseController
  #skip designer permissions from admin_controller
  skip_before_action :require_designer_permissions

  before_action :redirect_to_sub_org, only:[:index,:edit,:versions]
  layout :set_layout
  before_action :check_organization_workflow_enabled
  before_action :set_paper_trail_whodunnit, only: [:revert_document]
  before_action :get_organizations_if_supervisor
  before_action :require_staff_permissions, only: [:index]
  before_action :require_supervisor_permissions, except: [:index]

  def index
    org = get_org
    user_assignment = current_user.user_assignments.find_by organization_id: org.id if current_user
    @workflow_steps = WorkflowStep.where(organization_id: org.organization_ids.push(org.id))
    if has_role("supervisor") && params[:show_completed] == "true"
      @documents = Document.where(organization_id:org.descendants.pluck(:id)).where('documents.updated_at != documents.created_at')
      @documents = @documents.where(workflow_step_id: WorkflowStep.where(step_type:"end_step").pluck(:id) )
    elsif has_role("supervisor") && (params[:show_completed] == "false")
      @documents = Document.where(organization_id:org.descendants.pluck(:id)).where('documents.updated_at != documents.created_at')
      @documents = @documents.where(workflow_step_id: WorkflowStep.where.not(step_type:"end_step").pluck(:id) + [nil] )
    elsif has_role("supervisor") && params[:step_filter]
      @documents = Document.where(organization_id:org.descendants.pluck(:id)).where('documents.updated_at != documents.created_at')
      wfs = @workflow_steps.find_by(id: params[:step_filter].to_i)
      @documents = @documents.where(workflow_step_id: wfs&.id )
    else
      @documents = Document.where(organization_id:org.self_and_descendants.pluck(:id).push(org.id)).where('documents.updated_at != documents.created_at')
      @user_documents = @documents.where(user_id: current_user&.id) if current_user
      @documents = get_documents(current_user, @documents)
      @user_documents = @user_documents.where.not(id: @documents.pluck(:id)).reorder(created_at: :desc) if @user_documents
    end
    @documents = @documents.reorder(created_at: :desc).page(params[:page]).per(params[:per])
  end

  def edit
    get_document params[:id]
    if @document.organization.root_org_setting("inherit_workflows_from_parents")
      @workflow_steps = WorkflowStep.where(organization_id: @document.organization.organization_ids + [@document.organization_id]).order(step_type: :desc)
    else
      @workflow_steps = WorkflowStep.where(organization_id: @document.organization_id).order(step_type: :desc)
    end
    @periods = Period.where(organization_id: @document.organization&.parents&.pluck(:id).push(@document.organization&.id))
    @users = UserAssignment.where(organization_id:@document.organization.descendants.pluck(:id) + [@document.organization.id]).map(&:user)
    @users.push @document.user if @document.user
  end

  def update
    get_document params[:id]

    # if the publish target changed, clear out the published at date
    if params[:document][:workflow_step_id] != @document.workflow_step_id && !params[:document][:workflow_step_id].blank? && !params[:document][:user_id].blank?
      @wfs = WorkflowStep.find(params[:document][:workflow_step_id])
      if @wfs.step_type == "start_step"
        @user = User.find_by(id: params[:document][:user_id], archived: false)
        WorkflowMailer.welcome_email(@document, @user, @organization, @wfs.slug, component_allowed_liquid_variables(@document.workflow_step,User.find(params[:document][:user_id]),@organization, @document)).deliver_later
      end
    end

    # if the publish target changed, clear out the published at date
    if params[:document][:lms_course_id] && @document[:lms_course_id] != params[:document][:lms_course_id] || params[:document][:organization_id] && @document[:organization_id] != params[:document][:organization_id]
      @document[:lms_published_at] = nil
    end

    if @document.update document_params
      flash[:notice] = "You have assigned a document to #{@user.email} on #{@wfs.slug}" if @user && @wfs
      redirect_to workflow_document_index_path(org_path: params[:org_path])
    else
      flash[:error] = @document.errors.messages

      render 'edit'
    end
  end


  private

  def document_params
    params.require(:document).permit(:name, :lms_course_id, :workflow_step_id, :user_id, :period_id)
  end

  def get_documents user, documents
    docs = []
    documents.each_with_index do |document, index|
      if document.assigned_to? user
        docs.push document.id
      end
    end
    return Document.where(id: docs)
  end

  def get_organizations_if_supervisor
    if has_role('supervisor')
      get_organizations
      @organization = get_org
    end
  end

  def set_layout
    if has_role('supervisor')
      return 'admin'
    else
      return 'workflow'
    end
  end
end
