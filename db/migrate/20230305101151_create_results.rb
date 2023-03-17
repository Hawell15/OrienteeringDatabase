class CreateResults < ActiveRecord::Migration[6.1]
  def change
    create_table :results do |t|
      t.integer :place
      t.references :runner, null: false, foreign_key: true
      t.integer :time
      t.references :category, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :wre_points

      t.timestamps
    end
  end
end
