class RenameSyllabusToDocument < ActiveRecord::Migration
  def change
    rename_table :syllabuses, :documents

    reversible do |dir|
      dir.up do
        #fix version table data
        execute <<-SQL
          UPDATE versions
            SET versioned_type = 'Document'
            WHERE versioned_type = 'Syllabus'
        SQL
      end
      dir.down do
        #unfix version table data
        execute <<-SQL
          UPDATE versions
            SET versioned_type = 'Syllbaus'
            WHERE versioned_type = 'Document'
        SQL
      end
    end
  end
end
