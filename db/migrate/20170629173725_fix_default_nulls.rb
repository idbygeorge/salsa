class FixDefaultNulls < ActiveRecord::Migration[5.1]
  def change
      change_column :documents, :component_id, :integer, :null => true
  end
end
