# frozen_string_literal: true

class Users::SamlSessionsController < Devise::SamlSessionsController
  include DeviseSamlAuthenticatable::SamlConfig
  unloadable if Rails::VERSION::MAJOR < 4
  if Rails::VERSION::MAJOR < 5
    skip_before_filter :verify_authenticity_token
  else
    skip_before_action :verify_authenticity_token, raise: false
  end
  # before_action :configure_sign_in_params, only: [:create]

  #GET /users/saml/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    store_location_for(resource, admin_path)
    params[:organization_idp_entity_id] = OrganizationsSettingsHelper.idp_entity_id(get_org)
    super
  end

  def create
    super
    saml_response = OneLogin::RubySaml::Response.new(           params[:SAMLResponse],           settings: Devise.saml_config,           allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,)
    decorated_response = ::SamlAuthenticatable::SamlResponse.new(             saml_response,             User.attribute_map           )
    hash = {}
    decorated_response.attributes.resource_keys.each do |key|
      hash[key] = decorated_response.attribute_value_by_resource_key(key)
    end
    session[:saml_authenticated_user] = hash
    session[:authenticated_user] = UserAssignment.find_by_username(session[:saml_authenticated_user]["id"]).user.id
    session['institution'] = request.env['SERVER_NAME']
  end

end
