class AddTimestampsToOrgAndDocMeta < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :organization_meta
    add_timestamps :document_meta
  end
end
