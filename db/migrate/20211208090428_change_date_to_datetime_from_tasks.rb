class ChangeDateToDatetimeFromTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks, :date, :datetime
    rename_column :tasks, :date, :start_datetime
  end
end
