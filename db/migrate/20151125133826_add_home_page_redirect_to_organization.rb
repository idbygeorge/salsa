class AddHomePageRedirectToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :home_page_redirect, :string
  end
end
