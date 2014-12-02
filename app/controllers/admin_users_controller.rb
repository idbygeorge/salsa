class AdminUsersController < AdminController
  before_filter :get_organizations, only: [:index, :new, :edit, :show]

  def index
    @users = User.all
    @session = session
  end

  def show
    @user = User.find params[:id]
  end

  def edit
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create user_params
    redirect_to admin_user_path(id: @user[:id])
  end

  def update
    @user = User.find params[:id]
    @user.update user_params
    redirect_to admin_user_path(id: @user[:id])
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    redirect_to admi_users_path
  end

  def user_params
    params.require(:user).permit(:name, :id)
  end
end
