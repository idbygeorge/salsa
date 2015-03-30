class AddLmsInfoSlugToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :lms_info_slug, :string
  end
end
