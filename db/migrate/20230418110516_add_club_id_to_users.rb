class AddClubIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :club_id, :integer
  end
end
