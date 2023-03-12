class ChangeTypeColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :competitions, :type, :distance_tyoe
  end
end
