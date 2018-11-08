class AssignmentsController < AdminController
  before_action :set_assignment, only: %i[show edit update destroy]
  before_action :set_roles, only: %i[edit show new index create update]
  before_action :set_users
  before_action :set_namespace
  before_action :get_organizations, only: %i[index new edit create show]
  before_action :require_supervisor_permissions

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = @user.assignments
    @assignment = Assignment.new
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show; end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit; end

  # POST /assignments
  # POST /assignments.json
  def create
    @assignments = @user.assignments
    @assignment = Assignment.new(assignment_params)
    @assignment.user_id = @user.id

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to eval("#{@namespace}_user_team_assignments_path"), notice: 'Assignment was successfully created.' }
        format.json { render :index, status: :created, location: @assignment }
      else
        format.html { render :index }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    @assignment.user_id = @user.id
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to eval("#{@namespace}_user_team_assignments_url"), notice: 'Assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def set_users
    user_ids = []
    find_org_by_path(params[:slug]).self_and_descendants.each do |org|
      user_ids += org.users.pluck(:id)
    end
    @users = User.where(id: user_ids)
    @user = User.find(params[params.keys.detect { |k| k.to_s =~ /user_id/ }.to_sym])
  end

  def set_roles
    @roles = { 'Supervisor' => 'supervisor', 'Approver' => 'approver' }
  end

  def set_namespace
    @namespace =
      if params.key?(:organization_user_id)
        :organization
      else
        :admin
                   end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assignment_params
    params.require(:assignment).permit(:role, :user_id, :team_member_id)
  end
end
