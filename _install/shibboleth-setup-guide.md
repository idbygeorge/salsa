
## prerequisits
  must have https enabled and setup

# How to setup a shibboleth org

  go to the `/admin/organizations/new` page and in the shibboleth configuration section check the `enable shibboleth` box and fill in the fields according to what the idp told you below is an example

  (you will need the idp_cert or the idp_cert_fingerprint and algorithm)

  |idp_entity_id (required) | idp_sso_target_url (required) | idp_slo_target_url | authn_context | idp_cert |  idp_cert_fingerprint | idp_cert_fingerprint_algorithm |
  |-------------------------|-------------------------------|--------------------|---------------|----------|-----------------------|--------------------------------|
  | https://example-idp.com/idp/shibboleth | https://example-idp.com/idp/profile/SAML2/Redirect/SSO | https://example-idp.com/idp/profile/SAML2/Redirect/SLO | nil | certificate | nil | nil |   |



  the idp should also provide you with a metadata url that looks something like `https://shibboleth.example-idp.com/idp/shibboleth`
  more information on shibboleth metadata [here](https://wiki.shibboleth.net/confluence/display/CONCEPT/MetadataForSP)

  after creating the org shibboleth will be enabled for that org you will need to go to org.slug/user/saml/metadata and give that file to the idp for this shibboleth org
