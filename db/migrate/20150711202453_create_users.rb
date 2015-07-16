class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :phone
      t.string :email
      t.string :password_digest
      t.boolean :guest
      t.boolean :active
      t.boolean :admin

      t.timestamps null: false
    end
  end
end
