class AdminController < ApplicationController
  def logout
    session[:admin_authorized] = false

    redirect_to root_path;
  end
end
