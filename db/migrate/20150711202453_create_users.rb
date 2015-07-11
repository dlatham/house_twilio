class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :phone
      t.string :email
      t.boolean :guest
      t.boolean :active

      t.timestamps null: false
    end
  end
end
