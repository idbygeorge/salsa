class DefaultController < ApplicationController

  layout false
  before_action :init_view_folder

  def index
    root_org_slug = request.env['SERVER_NAME']
    org = Organization.find_by slug: root_org_slug

    if org and org.home_page_redirect?
      redirect_to org.home_page_redirect
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
<<<<<<< HEAD
    response.set_header('hostname', Socket.gethostname)
=======
    response.set_header('X-Status-Check-Hostname', @hostname)
>>>>>>> d360cfa9f83b89a58e2e5ec6fd87132fb3fb62d8

  end

  def maintenance
  	response.headers.delete('X-Frame-Options')
  end
  def tos
  end
  def faq
  end
end
