class AddUsersIdToGroups < ActiveRecord::Migration
  def change
  	add_column :groups, :users_id, :integer, array: true
  end
end
