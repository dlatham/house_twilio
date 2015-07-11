class CreateGreetings < ActiveRecord::Migration
  def change
    create_table :greetings do |t|
      t.string :text
      t.boolean :stranger
      t.string :time_of_day

      t.timestamps null: false
    end
  end
end
