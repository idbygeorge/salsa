class AddSubjectToComponent < ActiveRecord::Migration[5.1]
  def change
    change_table :components do |t|
      t.string :subject
    end
  end
end
