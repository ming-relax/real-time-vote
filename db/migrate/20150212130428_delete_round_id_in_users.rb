class DeleteRoundIdInUsers < ActiveRecord::Migration
  def change
    remove_column :users, :round_id
  end
end
