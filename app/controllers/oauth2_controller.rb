class Oauth2Controller < ApplicationController
  def login
    session[:canvas_access_token] = ''
    session[:authenticated_institution] = ''

    lms_connection_information

    session[:institution] = @institution
    session[:oauth_endpoint] = @oauth_endpoint

    redirect_to(@redirect_url)
  end

  def logout
    session[:institution] = ''
    session[:oauth_endpoint] = ''
    session[:canvas_access_token] = ''
    session[:authenticated_institution] = ''

    flash[:notice] = "You are disconnected from Canvas."

    redirect_to(:back)
  end

  def callback
    lms_connection_information

    code = params[:code]

    if code
      token = @lms_client.retrieve_access_token(code, @redirect_url)
      session[:canvas_access_token] = token

      flash[:notice] = 'You are connected to Canvas. Please Select a Course.'
      session[:authenticated_institution] = session[:institution]
    else
      flash[:error] = params[:error]
    end

    redirect_to syllabus_path(params[:syllabus_id]) + '#/select/course';
  end
end