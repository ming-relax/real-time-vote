class RenameColumnInRoom < ActiveRecord::Migration
  def change
  	rename_column :rooms, :user_id, :users_id
  end
end
