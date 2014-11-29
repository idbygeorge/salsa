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
    # params... save
    redirect user_path(id: @user[:id])
  end

  def update
    # params... save
    redirect user_path(id: @user[:id])
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    redirect users_path
  end
end
