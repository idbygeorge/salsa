class AddDisableDocumentViewSettingToOrganizations < ActiveRecord::Migration[5.1]
  def change
    change_table :organizations do |t|
      t.boolean :disable_document_view, default: false
    end
  end
end
