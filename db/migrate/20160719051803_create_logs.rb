class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :type
      t.string :phone
      t.string :body

      t.timestamps null: false
    end
  end
end
