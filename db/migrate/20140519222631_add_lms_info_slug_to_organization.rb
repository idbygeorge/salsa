class AddLmsInfoSlugToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :lms_info_slug, :string
  end
end
