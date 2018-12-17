class AdminUsersController < AdminController
  skip_before_action :require_designer_permissions
  before_action :require_admin_permissions, except: %i[import_users create_users]
  before_action :require_supervisor_permissions, only: %i[import_users create_users]
  before_action :get_organizations, only: %i[index new edit show edit_assignment import_users users_search create_users]
  before_action :get_roles, only: %i[edit_assignment assign index show]

  def index
    page = 1
    page = params[:page] if params[:page]
    show_archived = params[:show_archived] == 'true'

    @users = User.where(archived: show_archived)
    @users = @users.where(id: @user_ids) if defined?(@user_ids)
    @users = @users.order('name', 'email').all.page(params[:page]).per(15)

    @session = session
  end

  def show
    @user = User.find params[:id] if @user.blank?

    @user_assignments = @user.user_assignments if @user.user_assignments.count > 0

    @user_assignments = @user_assignments.where(organization_id: @organizations.pluck(:id)) if @user_assignments && params[:controller] == 'organization_users'

    @new_permission = @user.user_assignments.new
  end

  def edit
    @user = User.find params[:id]
  end

  def users_search(page = params[:page], per = 25)
    show_archived = params[:show_archived] == 'true'
    search_user_text = ''
    user_name = user_email = user_id = user_remote_id = nil

    user_email = params[:q] if params[:search_user_email]
    user_id = params[:q].to_i if params[:search_user_id]
    user_name = params[:q].to_s if params[:search_user_name]
    user_remote_id = params[:q] if params[:search_connected_account_id]

    if params[:controller] == 'organization_users'
      @organization = find_org_by_path(params[:slug])
      users = User.where(id: UserAssignment.where(organization_id: @organization.self_and_descendants.pluck(:id)).map(&:user))
      user_ids = users.where('email = ? OR id = ? OR name ~* ? ', user_email, user_id, user_name).pluck(:id)
      user_ids += UserAssignment.where(organization_id: @organization.id).where('lower(username) = ? ', user_remote_id.to_s.downcase).pluck(:user_id) unless user_remote_id.blank?
    else
      user_ids = User.where('email = ? OR id = ? OR name ~* ? ', user_email, user_id, user_name).pluck(:id)
      user_ids += UserAssignment.where('lower(username) = ? ', user_remote_id.to_s.downcase).pluck(:user_id) unless user_remote_id.blank?
    end
    @users = User.where(id: user_ids, archived: show_archived).page(page).per(per)
    render 'index'
  end

  def archive
    @user = User.find params["#{params[:controller].singularize}_id".to_sym]
    if @user.update(archived: true)
      flash[:notice] = "#{@user.email} has been archived"
    else
      flash[:error] = "#{@user.email} has NOT been archived because #{@user.errors.messages}"
    end
    redirect_to polymorphic_path([params[:controller]], org_path: params[:org_path])
  end

  def restore
    @user = User.find params["#{params[:controller].singularize}_id".to_sym]
    @user.update(archived: false)
    flash[:notice] = "#{@user.email} has been activated"
    redirect_to polymorphic_path([params[:controller]], org_path: params[:org_path])
  end

  def assign
    @user = User.find params[:user_assignment][:user_id]
    @user_assignment = UserAssignment.new user_assignment_params
    @user_assignment.organization_id = get_org.id unless has_role('admin')
    get_organizations
    @user_assignments = @user.user_assignments if @user.user_assignments.count > 0
    @new_permission = @user_assignment
    respond_to do |format|
      if @user_assignment.save
        format.html { redirect_to eval("#{ get_namespace }_user_path(org_path: params[:org_path], id: @user[:id])"), notice: 'User Assignment was successfully created.' }
        format.json { render :show, status: :created, location: @user_assignment }
      else
        format.html { render :show }
        format.json { render json: @user_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_namespace
    @namespace =
      if params[:controller] == 'admin_users'
        :admin
      else
        :organization
      end
  end

  def remove_assignment
    @user_assignment = get_user_assignment(params[:id])
    @user_assignment.destroy if @user_assignment

    redirect_to polymorphic_path([params[:controller].singularize], id: @user_assignment.user_id, org_path: params[:org_path])
  end

  def edit_assignment
    @roles.delete('Global Administrator') unless has_role('admin')

    @user_assignment = get_user_assignment(params[:id])
  end

  def update_assignment
    @user_assignment = UserAssignment.find params[:id]

    @user_assignment.errors.add('user_id', 'Invalid User ID') if params[:user_assignment][:user_id].to_i != @user_assignment.user_id

    @user_assignment.errors.add('role', 'Invalid role') if !get_roles.value?(params[:user_assignment][:role]) && !has_role('admin')

    @user_assignment.update(user_assignment_params) if !@user_assignment.errors.any?

    if @user_assignment.errors.any?
      get_organizations

      render action: :edit_assignment
    else
      redirect_to polymorphic_path([params[:controller].singularize], id: @user_assignment.user_id, org_path: params[:org_path])
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

    if @user.archived && params[:controller] == 'organization_users'
      @user.archived = false
    end
    @user_saved = false
    if @user.save
      @user_saved = true

      redirect_to polymorphic_path([params[:controller].singularize], id: @user.id, org_path: params[:org_path])
    else
      flash[:error] = 'Error creating user'
      render action: :new
    end
  end

  def update
    @user = User.find params[:id]
    if @user.update user_params
      redirect_to polymorphic_path([params[:controller].singularize], id: @user.id, org_path: params[:org_path])
    else
      return render action: :edit, params: params
    end
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy

    redirect_to polymorphic_path([params[:controller]], org_path: params[:org_path])
  end

  private

  def get_user_assignment(id)
    if params[:controller] == 'admin'
      user_assignment = UserAssignment.find id
    else
      user_assignment = UserAssignment.find_by id: id, organization_id: get_organizations.pluck(:id)
    end
    user_assignment
  end

  def user_activation_token(user)
    if user.activation_digest.blank?
      user.activation_digest = SecureRandom.urlsafe_base64.to_s
    end
  end

  def user_params
    params.require(:user).require(:name)
    params.require(:user).require(:email)

    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_assignment_params
    # global admin role, doens't have an organization, all other roles require one
    if params[:user_assignment][:role] == 'admin' && has_role("admin")
      params[:user_assignment][:organization_id] = nil
      params[:user_assignment][:cascades] = true
    end

    if has_role('admin')
      params.require(:user_assignment).permit(:user_id, :username, :role, :organization_id, :cascades)
    else
      params.require(:user_assignment).permit(:user_id, :username, :role, :cascades)
    end
  end
end
