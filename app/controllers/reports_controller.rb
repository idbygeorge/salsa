class ReportsController < ApplicationController
  before_filter :require_admin_password
  before_filter :get_organizations, only: [:index, :new, :edit, :show]
  layout 'admin'

  def index
  end
end
