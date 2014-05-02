class DefaultController < ApplicationController

  layout false
  
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
