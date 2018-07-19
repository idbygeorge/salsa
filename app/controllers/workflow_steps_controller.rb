class WorkflowStepsController < OrganizationsController
  skip_before_action :require_designer_permissions
  skip_before_action :require_admin_permissions
  skip_before_action :require_organization_admin_permissions
  before_action :check_organization_workflow_enabled
  before_action :set_workflow_step, only: [:show, :edit, :update, :destroy]
  before_action :set_workflow_steps
  before_action :require_supervisor_permissions
  before_action :redirect_if_wrong_organization, only: [:show, :edit, :update, :destroy]
  
  # GET /workflow_steps
  # GET /workflow_steps.json
  def index
    org = Organization.find_by(slug: params[:slug])
    org_ids = org.organization_ids
    @workflows = WorkflowStep.workflows org_ids
    workflow_array = []
    @workflows.each do|wf|
      wf.map(&:id).each do |wfid|
        workflow_array.push wfid
      end
    end
    @workflow_steps = WorkflowStep.where(organization_id: org_ids).where.not(id: workflow_array).order(slug: :asc, next_workflow_step_id: :asc)
    return
  end

  # GET /workflow_steps/1
  # GET /workflow_steps/1.json
  def show
  end

  # GET /workflow_steps/new
  def new
    @workflow_step = WorkflowStep.new
  end

  # GET /workflow_steps/1/edit
  def edit
  end

  # POST /workflow_steps
  # POST /workflow_steps.json
  def create
    @workflow_step = WorkflowStep.new(workflow_step_params)
    @workflow_step.organization_id = Organization.find_by(slug: params[:slug]).id

    respond_to do |format|
      if @workflow_step.save
        format.html { redirect_to workflow_step_path(params[:slug], @workflow_step), notice: 'Workflow step was successfully created.' }
        format.json { render :show, status: :created, location: @workflow_step }
      else
        format.html { render :new }
        format.json { render json: @workflow_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workflow_steps/1
  # PATCH/PUT /workflow_steps/1.json
  def update
    respond_to do |format|
      if @workflow_step.update(workflow_step_params)
        format.html { redirect_to workflow_step_path(params[:slug], @workflow_step), notice: 'Workflow step was successfully updated.' }
        format.json { render :show, status: :ok, location: @workflow_step }
      else
        format.html { render :edit }
        format.json { render json: @workflow_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_steps/1
  # DELETE /workflow_steps/1.json
  def destroy
    @workflow_step.destroy
    respond_to do |format|
      format.html { redirect_to workflow_steps_url, notice: 'Workflow step was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def redirect_if_wrong_organization
      if params[:slug] != @workflow_step.organization.slug
        if params[:action] != 'index'
          redirect_to "/admin/organization/#{@workflow_step.organization.slug}/workflow_steps/#{params[:id]}/#{params[:action]}"
        else
          redirect_to workflow_steps_path(@workflow_steps.organization.slug)
        end
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_workflow_step
      @workflow_step = WorkflowStep.find(params[:id])
    end

    def set_workflow_steps
      organization_ids = Organization.find_by(slug: params[:slug]).organization_ids
      @workflow_steps = WorkflowStep.where(organization_id: organization_ids)
      if @workflow_step
        @workflow_steps = @workflow_steps.where.not(id: @workflow_step.id)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workflow_step_params
      params.require(:workflow_step).permit(:slug, :name, :organization_id, :next_workflow_step_id, :start_step, :end_step)
    end
end
