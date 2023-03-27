class CreateRunners < ActiveRecord::Migration[6.1]
  def change
    create_table :runners do |t|
      t.string :runner_name
      t.string :surname
      t.date :dob, default: Time.now.as_json
      t.references :club, default: 0
      t.string :gender
      t.integer :wre_id
      t.references :best_category, default: 10
      t.references :category, default: 10
      t.date :category_valid, default: "2100-01-01"
      t.integer :sprint_wre_rang
      t.integer :forest_wre_rang
      t.integer :sprint_wre_place
      t.integer :forest_wre_place
      t.string :checksum

      t.timestamps
    end
  end
end
