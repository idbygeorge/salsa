class Admin::PeriodsController < AdminController
  before_action :get_organizations, only: [:index]
  def index
    @periods = Period.all.page(params[:page]).per(params[:per])
  end

  def new
    @period = Period.new
  end


  # POST /periods
  # POST /periods.json
  def create
    @period = Period.new(period_params)
    respond_to do |format|
      if @period.save
        format.html { redirect_to admin_periods_path(params[:slug]), notice: 'Period was successfully created.' }
        format.json { render :index, status: :created }
      else
        format.html { render :new }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  private
  def period_params
    params.require(:period).permit(:name, :slug, :organization_id, :start_date, :duration, :cycle, :sequence, :is_default)
  end
end
