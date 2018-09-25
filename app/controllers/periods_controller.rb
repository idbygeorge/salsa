class PeriodsController < OrganizationsController
  #Skip permissions defined in OrganizationsController
  skip_before_action :require_admin_permissions
  skip_before_action :require_designer_permissions

  before_action :redirect_to_sub_org
  before_action :get_organizations, only: [:index]
  before_action :require_organization_admin_permissions

  def index
    @organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    @periods = Period.where(organization_id: @organization.id).reorder(start_date: :desc).page(params[:page]).per(params[:per])
  end

  def new
    @organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    @period = Period.new
  end

  def show
    @organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    @period = Period.find(params[:id])
  end

  def edit
    @organization = Organization.all.select{ |o| o.full_slug == params[:slug] }.first
    @period = Period.find(params[:id])
  end

  # POST /periods
  # POST /periods.json
  def create
    @period = Period.new(period_params)
    @period.organization_id = Organization.all.select{ |o| o.full_slug == params[:slug] }.first.id
    respond_to do |format|
      if @period.save
        format.html { redirect_to periods_path(params[:slug], org_path: params[:org_path]), notice: 'Period was successfully created.' }
        format.json { render :index, status: :created }
      else
        format.html { render :new }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @period = Period.find(params[:id])
    @period.organization_id = Organization.all.select{ |o| o.full_slug == params[:slug] }.first.id
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to periods_path(params[:slug], org_path: params[:org_path]), notice: 'Period was successfully updated.' }
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
    params.require(:period).permit(:name, :slug, :start_date, :duration, :is_default)
  end
end
