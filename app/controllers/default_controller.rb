class DefaultController < ApplicationController

  layout false
  before_filter :init_view_folder

  def index
    render layout: 'home'
  end

  def maintenance
  	response.headers.delete('X-Frame-Options')
  end
  def tos
  end
  def faq
  end
end
