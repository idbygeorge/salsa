class Oauth2Controller < ApplicationController
  def login
    if !params[:institution]
      institution = 'usu'
    else
      institution = params[:institution]
    end

    oautuh_endpoint = "https://#{institution}.instructure.com"
    
    session[:institution] = params[:institution]
    session[:oautuh_endpoint] = oautuh_endpoint

    lms_client = Canvas::API.new(:host => oautuh_endpoint, :client_id => APP_CONFIG['canvas_id'], :secret => APP_CONFIG['canvas_key'])

    url = "#{lms_client.oauth_url(APP_CONFIG['oauth_callback_uri'])}%3Fsyllabus_id%3D#{params[:syllabus_id]}"
    redirect_to(url)
  end

  def callback
    code = params[:code]

    if code
      lms_client = Canvas::API.new(:host => session[:oautuh_endpoint], :client_id => APP_CONFIG['canvas_id'], :secret => APP_CONFIG['canvas_key'])

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
