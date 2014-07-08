class AddGroupToOfflineRecords < ActiveRecord::Migration
  def up
    add_column :offline_records, :group_id, :integer, :nil => false
    add_column :offline_records, :round_id, :integer, :nil => false
    add_column :offline_records, :created_at, :date, :nil => false
  end

  def down
    remove_column :offline_records, :group_id
    remove_column :offline_records, :round_id
    remove_column :offline_records, :created_at
  end
end
