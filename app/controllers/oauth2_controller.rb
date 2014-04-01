class Oauth2Controller < ApplicationController
  before_filter :lms_connection_information, only: [:login, :callback]
  def login
    session[:institution] = @institution
    session[:oauth_endpoint] = @oauth_endpoint
    session[:canvas_access_token] = ''
    session[:authenticated_institution] = ''

    redirect_to(@redirect_url)
  end

  def logout
    session[:institution] = ''
    session[:oauth_endpoint] = ''
    session[:canvas_access_token] = ''
    session[:authenticated_institution] = ''

    flash[:notice] = "This application has been detached from canvas"

    redirect_to(:back)
  end

  def callback
    code = params[:code]

    if code
      token = @lms_client.retrieve_access_token(code, @redirect_url)
      session[:canvas_access_token] = token

      flash[:notice] = 'Canvas authentication successful'
      session[:authenticated_institution] = session[:institution]
    else
      flash[:error] = params[:error]
    end

    redirect_to syllabus_path(params[:syllabus_id]) + '#/compilation/clipboard';
  end
end