class AddTrackMetaInfoFromDocumentToOrganization < ActiveRecord::Migration[5.1]
  def change
    change_table :organizations do |t|
      t.boolean :track_meta_info_from_document
    end
  end
end
