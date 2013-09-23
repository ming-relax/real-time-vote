class AddRoomGroupEarningToUsers < ActiveRecord::Migration
  def change
    add_column :users, :room_id, :integer
    add_column :users, :group_id, :integer
    add_column :users, :total_earning, :integer
  end
end
