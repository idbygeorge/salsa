module OrganizationsHelper
  def self.entity_id(params)
    if params[:organization_idp_entity_id]
      return params[:organization_idp_entity_id]
    elsif params[:SAMLRequest]
      OneLogin::RubySaml::SloLogoutrequest.new(
        params[:SAMLRequest],
        settings: Devise.saml_config,
        allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
      ).issuer
    elsif params[:SAMLResponse]
      OneLogin::RubySaml::Response.new(
        params[:SAMLResponse],
        settings: Devise.saml_config,
        allowed_clock_drift: Devise.allowed_clock_drift_in_seconds,
      ).issuers.first
    end
  end


end
