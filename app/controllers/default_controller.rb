class DefaultController < ApplicationController

  layout false
  
  def index
  end

  def maintenance
  	response.headers.delete('X-Frame-Options')
  end
  def tos
  end
end
