class AdminDocumentsController < AdminController
  before_action :get_organizations, only: [:new, :edit, :update]
  before_action :require_designer_permissions

  layout 'admin'

  def new
    @document = Document.new
  end

  def edit
    get_document params[:id]
    if @document.organization.inherit_workflows_from_parents
      @workflow_steps = WorkflowStep.where(organization_id: @document.organization.parents.map{|x| x[:id]}).order(start_step: :desc)
    else
      @workflow_steps = WorkflowStep.where(organization_id: @document.organization_id, start_step: true)
    end
  end

  def update
    get_document params[:id]

    # if the publish target changed, clear out the published at date
    if params[:document][:lms_course_id] && @document[:lms_course_id] != params[:document][:lms_course_id] ||
       params[:document][:organization_id] && @document[:organization_id] != params[:document][:organization_id]
      @document[:lms_published_at] = nil
    end

    if @document.update document_params

      slug = ''
      if @document.organization
        slug = @document.organization.slug
      end

      redirect_to organization_path(slug: slug)
    else
      flash[:error] = @document.errors.messages

      render 'edit'
    end
  end

  def delete
  end

  private

  def get_document id=params[:id]
    @document = Document.find_by id: id
  end

  def document_params
    params.require(:document).permit(:name, :lms_course_id, :workflow_step_id, :organization_id, :user_id)
  end
end
