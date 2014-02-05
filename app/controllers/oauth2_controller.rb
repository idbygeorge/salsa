class Oauth2Controller < ApplicationController
  def login
    url = "#{canvas_client.oauth_url(APP_CONFIG['oauth_callback_uri'])}%3Fsyllabus_id%3D#{params[:syllabus_id]}"
    redirect_to(url)
  end

  def callback
    code = params[:code]
    url = "#{canvas_client.oauth_url(APP_CONFIG['oauth_callback_uri'])}%3Fsyllabus_id%3D#{params[:syllabus_id]}"
    token = canvas_client.retrieve_access_token(code, url)
    session[:canvas_access_token] = token
    #TODO: set logged in
    redirect_to syllabus_path(params[:syllabus_id])
  end

  protected

  def canvas_client
    Canvas::API.new(:host => APP_CONFIG['canvas_api_endpoint'], :client_id => APP_CONFIG['canvas_id'], :secret => APP_CONFIG['canvas_key'])
  end
end
