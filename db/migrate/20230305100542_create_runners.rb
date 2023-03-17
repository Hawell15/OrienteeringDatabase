class CreateRunners < ActiveRecord::Migration[6.1]
  def change
    create_table :runners do |t|
      t.string :runner_name
      t.string :surname
      t.date :dob
      t.references :club
      t.string :gender
      t.integer :wre_id
      t.references :best_category
      t.references :category
      t.date :category_valid
      t.integer :sprint_wre_rang
      t.integer :forest_wre_rang
      t.integer :sprint_wre_place
      t.integer :forest_wre_place
      t.string :checksum

      t.timestamps
    end
  end
end
