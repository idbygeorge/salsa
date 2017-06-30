class AddHomePageRedirectToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :home_page_redirect, :string
  end
end
