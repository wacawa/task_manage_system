class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.datetime :expiration_date
      t.boolean :google

      t.timestamps
    end
  end
end
