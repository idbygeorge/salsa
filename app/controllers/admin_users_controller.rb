class AdminUsersController < AdminController
  before_filter :require_admin_permissions
  before_filter :get_organizations, only: [:index, :new, :edit, :show, :edit_assignment]

  def index
    @users = User.all
    @session = session
  end

  def show
    @user = User.find params[:id]
    @user_assignments = @user.user_assignments if @user.user_assignments.count > 0

    @new_permission = @user.user_assignments.new
  end

  def edit
    @user = User.find params[:id]
  end

  def assign
    @user = User.find params[:user_assignment][:user_id]

    @user_assignment = UserAssignment.create user_assignment_params
    redirect_to admin_user_path id: @user[:id]
  end

  def remove_assignment
    @user_assignment = UserAssignment.find params[:id]
    @user_assignment.destroy

    redirect_to admin_user_path @user_assignment[:user_id]
  end

  def edit_assignment
    @user_assignment = UserAssignment.find params[:id]
  end

  def update_assignment
    @user = User.find params[:user_assignment][:user_id]

    @user_assignment = UserAssignment.update params[:id], user_assignment_params
    redirect_to admin_user_path id: @user[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new

    @user.attributes = user_params

    # unless @user.password
    #     @user.password = SecureRandom.urlsafe_base64
    #     @user.password_confirmation = @user.password
    # end

    if @user.save
        return redirect_to admin_user_path(id: @user[:id])
    else
        flash[:error] = 'Error creating user'
        return render action: :new
    end
  end

  def update
    @user = User.find params[:id]
    @user.update user_params
    redirect_to admin_user_path(id: @user[:id])
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    redirect_to admin_users_path
  end

  def user_params
    params.require(:user).require(:name)
    params.require(:user).require(:email)

    params.require(:user).permit(:name, :email, :id, :password, :password_confirmation)
  end

  def user_assignment_params
    params.require(:user_assignment).require(:user_id)
    params.require(:user_assignment).require(:role)
    params.require(:user_assignment).require(:organization_id)

    params.require(:user_assignment).permit(:user_id, :username, :role, :organization_id, :cascades)
  end
end
