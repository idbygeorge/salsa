class DefaultController < ApplicationController

  layout false
  before_filter :init_view_folder

  def index
    root_org_slug = request.env['SERVER_NAME']
    org = Organization.find_by slug: root_org_slug

    if org.home_page_redirect?
      redirect_to org.home_page_redirect
    else
      render layout: 'home'
    end
  end

  def maintenance
  	response.headers.delete('X-Frame-Options')
  end
  def tos
  end
  def faq
  end
end
