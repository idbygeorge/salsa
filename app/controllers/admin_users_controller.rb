class AdminUsersController < AdminController
  skip_before_action :require_designer_permissions
  before_action :require_admin_permissions, except:[:import_users,:create_users]
  before_action :require_supervisor_permissions, only:[:import_users,:create_users]
  before_action :get_organizations, only: [:index, :new, :edit, :show, :edit_assignment, :import_users]
  before_action :get_roles, only: [:edit_assignment, :assign, :index ,:show]

  def index
    page = 1
    page = params[:page] if params[:page]
    show_archived = params[:show_archived] == "true"
    @users = User.where(archived: show_archived).order('name', 'email').all.page(params[:page]).per(15)
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

  def archive
    @user = User.find params["#{params[:controller].singularize}_id".to_sym]
    @user.update(archived: true)
    flash[:notice] = "#{@user.email} has been archived"
    return redirect_to polymorphic_path([params[:controller]])
  end

  def restore
    @user = User.find params["#{params[:controller].singularize}_id".to_sym]
    @user.update(archived: false)
    flash[:notice] = "#{@user.email} has been restored"
    return redirect_to polymorphic_path([params[:controller]])
  end

  def assign
    @user = User.find params[:user_assignment][:user_id]
    @user_assignment = UserAssignment.new user_assignment_params
    if !has_role("admin")
      @user_assignment.organization_id = get_org.id
    end
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

    redirect_to polymorphic_path([params[:controller].singularize],id: @user_assignment.user_id)
  end

  def edit_assignment
    if !has_role("admin")
      @roles.delete("Global Administrator")
    end
    @user_assignment = UserAssignment.find params[:id]
  end

  def update_assignment
    @user = User.find params[:user_assignment][:user_id]

    @user_assignment = UserAssignment.update params[:id], user_assignment_params

    @user_assignment.errors.add('role', 'Invalid role') if !get_roles.has_value?(params[:user_assignment][:role]) && !has_role("admin")

    if @user_assignment.errors.any?
      get_organizations

      render action: :edit_assignment
    else
      redirect_to polymorphic_path([params[:controller].singularize],id: @user.id)
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
        return redirect_to polymorphic_path([params[:controller].singularize],id: @user.id)
    else
        flash[:error] = 'Error creating user'
        return render action: :new
    end
  end

  def update
    @user = User.find params[:id]
    @user.update user_params
    redirect_to polymorphic_path([params[:controller].singularize],id: @user.id)
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    redirect_to polymorphic_path([params[:controller]])
  end


  private

  def user_activation_token user
    if user.activation_digest.blank?
      user.activation_digest = SecureRandom.urlsafe_base64.to_s
    end
  end


  def user_params
    params.require(:user).require(:name)
    params.require(:user).require(:email)

    params.require(:user).permit(:name, :email, :id, :password, :password_confirmation)
  end

  def user_assignment_params

    # global admin role, doens't have an organization, all other roles require one
    if params[:user_assignment][:role] == 'admin'
      params[:user_assignment][:organization_id] = nil
      params[:user_assignment][:cascades] = true
    end
    if has_role("admin")
      params.require(:user_assignment).permit(:user_id, :username, :role, :organization_id, :cascades)
    else
      params.require(:user_assignment).permit(:user_id, :username, :role, :cascades)
    end
  end
end
