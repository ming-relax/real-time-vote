class AddAckToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :acked_users, :integer, array: true
  end
end
