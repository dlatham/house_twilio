class LogFixColumnName < ActiveRecord::Migration
  def change
    rename_column :logs, :type, :response
  end
end
