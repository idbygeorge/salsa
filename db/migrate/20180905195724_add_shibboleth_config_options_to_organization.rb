class AddShibbolethConfigOptionsToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :organizations, :enable_shibboleth, :boolean, default: false
    add_column :organizations, :idp_sso_target_url, :string
    add_column :organizations, :idp_slo_target_url, :string
    add_column :organizations, :idp_entity_id, :string
    add_column :organizations, :idp_cert, :text
    add_column :organizations, :idp_cert_fingerprint, :string
    add_column :organizations, :idp_cert_fingerprint_algorithm, :string
    add_column :organizations, :authn_context, :string
  end
end
