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
      
      # find the org to bind this to
      org = Organization.find_by slug: session[:institution]
      
      # if there is a matching org, save the salsa under that org
      if org
        salsa = Syllabus.find_by edit_id: params[:syllabus_id]
        
        if salsa
          salsa.update(organization_id: org[:id])
        end
      end
    else
      flash[:error] = params[:error]
    end

    redirect_to syllabus_path(params[:syllabus_id]) + '#/select/course';
  end
end