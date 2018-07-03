class AddEnableAnonymousActionsToOrganization < ActiveRecord::Migration[5.1]
  def change
      add_column :organizations, :enable_anonymous_actions, :boolean, default: true
  end
end
