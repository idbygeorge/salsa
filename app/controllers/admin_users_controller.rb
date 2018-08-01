class AdminUsersController < AdminController
  before_action :require_admin_permissions, exept:[:import_users]
  before_action :require_supervisor_permissions, only:[:import_users]
  before_action :get_organizations, only: [:index, :new, :edit, :show, :edit_assignment, :import_users]
  before_action :get_roles, only: [:edit_assignment, :assign, :index ,:show]

  def index
    page = 1
    page = params[:page] if params[:page]

    @users = User.order('name', 'email').all.page(params[:page]).per(15)
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
      @user_assignment = UserAssignment.new user_assignment_params
      get_organizations
      @user_assignments = @user.user_assignments if @user.user_assignments.count > 0
      @new_permission = @user_assignment
      respond_to do |format|
        if @user_assignment.save
          format.html { redirect_to admin_user_path id: @user[:id], notice: 'User Assignment was successfully created.' }
          format.json { render :show, status: :created, location: @user_assignment }
        else
          format.html { render :show }
          format.json { render json: @user_assignment.errors, status: :unprocessable_entity }
        end
      end
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

    if @user_assignment.errors.any?
      get_organizations

      render action: :edit_assignment
    else
      redirect_to admin_user_path id: @user[:id]
    end
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

  def create_users
    org = get_org
    users_emails = params[:users][:emails].delete(' ').split(/,|\r\n/).delete_if {|x| x == "\r" }
    user_errors = Array.new
    users_emails.each do |user_email|
      user = User.create(name: "New User", email:user_email, password: "#{rand(36**40).to_s(36)}", activated:false)
      UserAssignment.create(role:"staff",user_id:user.id,organization_id:org.id) if user
      user.errors.messages.each do |error|
        user_errors.push "Could not create user with email: '#{user.email}' because: #{error[0]} #{error[1][0]}" if user.errors
      end
      UserMailer.welcome_email.deliver_later
    end
    flash[:notice] = "Users created successfully" if user_errors == [] && users_emails != []
    flash[:errors] = user_errors
    redirect_to admin_import_users_path
  end

  def import_users
  end

  private

  def user_params
    params.require(:user).require(:name)
    params.require(:user).require(:email)

    params.require(:user).permit(:name, :email, :id, :password, :password_confirmation)
  end

  def user_assignment_params
    params.require(:user_assignment).require(:user_id)
    params.require(:user_assignment).require(:role)

    # global admin role, doens't have an organization, all other roles require one
    if params[:user_assignment][:role] == 'admin'
      params[:user_assignment][:organization_id] = nil
      params[:user_assignment][:cascades] = true
    end

    params.require(:user_assignment).permit(:user_id, :username, :role, :organization_id, :cascades)
  end
end
