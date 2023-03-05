class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :category_name
      t.string :full_name
      t.integer :points

      t.timestamps
    end
  end
end
