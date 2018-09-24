class DefaultController < ApplicationController

  layout false
  before_action :init_view_folder
  before_action :add_allow_credentials_headers, only: [:status_server]


  def index
    root_org_slug = get_org_slug
    org = Organization.all.select{ |o| o.full_slug == get_org_path }.first

    if org and org.home_page_redirect?
      redirect_to org.home_page_redirect, org_path: params[:org_path]
    else
      render layout: 'home'
    end
  end

  def status_server
    if Organization.count
      @status = 200
    else
      @status = 500
    end
    @hostname = Socket.gethostname
    render 'default/status_server',:status => @status
    headers['Last-Modified'] = Time.now.httpdate
    response.set_header('X-Status-Check-Hostname', @hostname)

  end

  def maintenance
  	response.headers.delete('X-Frame-Options')
  end
  def tos
  end
  def faq
  end
  private
  def add_allow_credentials_headers
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*' # the domain you're making the request from
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Headers'] = 'accept, content-type'
    response.headers['X-Forwarded-Proto'] = 'https'
  end

end
