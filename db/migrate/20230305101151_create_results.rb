class CreateResults < ActiveRecord::Migration[6.1]
  def change
    create_table :results do |t|
      t.integer :place
      t.references :runner, null: false, foreign_key: true
      t.integer :time, default: 0
      t.references :category, null: false, foreign_key: true, default: 10
      t.references :group, null: false, foreign_key: true, default: 0
      t.integer :wre_points
      t.date :date

      t.timestamps
    end
  end
end
