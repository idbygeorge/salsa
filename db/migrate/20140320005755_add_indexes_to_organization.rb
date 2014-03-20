class AddIndexesToOrganization < ActiveRecord::Migration
  def change
  	add_index :organizations, :parent_id
    add_index :organizations, :lft
    add_index :organizations, :rgt
    add_index :organizations, :depth
    add_index :organizations, [:slug, :parent_id], unique: true
  end
end
