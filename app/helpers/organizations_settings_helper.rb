
module OrganizationsSettingsHelper
  def self.idp_entity_id(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.idp_entity_id
  end
  def self.idp_sso_target_url(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.idp_sso_target_url
  end
  def self.idp_slo_target_url(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.idp_slo_target_url
  end
  def self.idp_cert(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.idp_cert
  end
  def self.idp_cert_fingerprint(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.idp_cert_fingerprint
  end
  def self.idp_cert_fingerprint_algorithm(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.idp_cert_fingerprint_algorithm
  end
  def self.authn_context(organization)
    org = organization.self_and_ancestors.where(enable_shibboleth: true).reorder(:depth).last
    return org.authn_context
  end
end
