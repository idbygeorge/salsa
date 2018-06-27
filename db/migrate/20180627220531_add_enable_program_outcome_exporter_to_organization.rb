class AddEnableProgramOutcomeExporterToOrganization < ActiveRecord::Migration[5.1]
  def change
    change_table :organizations do |t|
      t.boolean :enable_program_outcome_exporter
    end
  end
end
