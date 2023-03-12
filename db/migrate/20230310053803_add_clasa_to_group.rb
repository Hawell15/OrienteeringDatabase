class AddClasaToGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :clasa, :string
  end
end
