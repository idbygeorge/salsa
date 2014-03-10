class Oauth2Controller < ApplicationController
  def login
    if !params[:institution]
      institution = 'usu'
    else
      institution = params[:institution]
    end

    oauth_endpoint = "https://#{institution}.instructure.com"
    
    session[:institution] = params[:institution]
    session[:oauth_endpoint] = oauth_endpoint

    lms_client = Canvas::API.new(:host => oauth_endpoint, :client_id => APP_CONFIG['canvas_id'], :secret => APP_CONFIG['canvas_key'])

    url = "#{lms_client.oauth_url(APP_CONFIG['oauth_callback_uri'])}%3Fsyllabus_id%3D#{params[:syllabus_id]}"
    redirect_to(url)
  end

  def logout
    session[:institution] = ''
    session[:oauth_endpoint] = ''
    session[:canvas_access_token] = ''

    flash[:notice] = "This application has been detached from canvas"

    redirect_to(:back)
  end

  def callback
    code = params[:code]

    if code
      lms_client = Canvas::API.new(:host => session[:oauth_endpoint], :client_id => APP_CONFIG['canvas_id'], :secret => APP_CONFIG['canvas_key'])

      url = "#{lms_client.oauth_url(APP_CONFIG['oauth_callback_uri'])}%3Fsyllabus_id%3D#{params[:syllabus_id]}"
      token = lms_client.retrieve_access_token(code, url)
      session[:canvas_access_token] = token
      #TODO: set logged in

      flash[:notice] = 'Canvas authentication successful'

      session[:authenticated_institution] = session[:institution]
    else
      flash[:error] = params[:error]
    end

    redirect_to syllabus_path(params[:syllabus_id])
  end

  protected

  def canvas_client
    Canvas::API.new(:host => APP_CONFIG['canvas_api_endpoint'], :client_id => APP_CONFIG['canvas_id'], :secret => APP_CONFIG['canvas_key'])
  end
end
