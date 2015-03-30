class AddTimestampsToOrgAndDocMeta < ActiveRecord::Migration
  def change
    add_timestamps :organization_meta
    add_timestamps :document_meta
  end
end
