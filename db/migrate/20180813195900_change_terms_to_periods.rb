class ChangeTermsToPeriods < ActiveRecord::Migration[5.1]
  def change
    rename_table :terms, :periods
  end
end
