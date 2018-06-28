class AddEnableProgramOutcomeExporterToOrganization < ActiveRecord::Migration[5.1]
  def change
    change_table :organizations do |t|
      t.string :export_type, default: "default"
    end
  end
end
