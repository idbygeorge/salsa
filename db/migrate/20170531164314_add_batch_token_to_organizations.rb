class AddBatchTokenToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :republish_batch_token, :string, :null => true
  end
end
