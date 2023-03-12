class ChangeTyoeColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :competitions, :distance_tyoe, :distance_type
  end
end
