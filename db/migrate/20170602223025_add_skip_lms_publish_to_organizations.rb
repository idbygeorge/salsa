class AddSkipLmsPublishToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :skip_lms_publish, :boolean
  end
end
