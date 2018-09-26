class Admin::PeriodsController < AdminController
  before_action :get_organizations, only: [:index,:show,:edit,:new]
  def index
    @periods = Period.all.reorder(created_at: :desc).page(params[:page]).per(params[:per])
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
    respond_to do |format|
      if @period.save
        format.html { redirect_to admin_periods_path(params[:slug], org_path: params[:org_path]), notice: 'Period was successfully created.' }
        format.json { render :index, status: :created }
      else
        format.html { render :new }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @period = Period.find(params[:id])
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to admin_periods_path(params[:slug], org_path: params[:org_path]), notice: 'Period was successfully updated.' }
        format.json { render :index, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def period_params
    params.require(:period).permit(:name, :slug, :organization_id, :start_date, :duration, :is_default)
  end
end
