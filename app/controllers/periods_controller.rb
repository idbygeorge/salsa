class PeriodsController < OrganizationsController
  skip_before_action :require_admin_permissions
  skip_before_action :require_organization_admin_permissions
  skip_before_action :require_designer_permissions
  before_action :get_organizations, only: [:index]
  before_action :require_organization_admin_permissions

  def index
    @periods = Period.where(organization_id: Organization.find_by(slug:params[:slug]).id).page(params[:page]).per(params[:per])
  end

  def new
    @period = Period.new
  end

  def show
    @period = Period.find(params[:id])
  end

  def edit
    @period = Period.find(params[:id])
  end

  # POST /periods
  # POST /periods.json
  def create
    @period = Period.new(period_params)
    @period.organization_id = Organization.find_by(slug:params[:slug]).id
    respond_to do |format|
      if @period.save
        format.html { redirect_to periods_path(params[:slug]), notice: 'Period was successfully created.' }
        format.json { render :index, status: :created }
      else
        format.html { render :new }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @period = Period.find(params[:id])
    @period.organization_id = Organization.find_by(slug:params[:slug]).id
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to periods_path(params[:slug]), notice: 'Period was successfully updated.' }
        format.json { render :index, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def find_or_create_period
    end


  def period_params
    params.require(:period).permit(:name, :slug, :start_date, :duration, :cycle, :sequence, :is_default)
  end
end
