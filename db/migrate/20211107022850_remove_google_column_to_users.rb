class RemoveGoogleColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :google
  end
end
