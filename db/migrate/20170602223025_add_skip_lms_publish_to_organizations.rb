class AddSkipLmsPublishToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :skip_lms_publish, :boolean
  end
end
