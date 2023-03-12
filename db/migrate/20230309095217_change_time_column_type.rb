class ChangeTimeColumnType < ActiveRecord::Migration[6.1]
  def change
    change_table :results do |t|
      t.change :time, :integer
    end
  end
end
