class AddOfflineRecord < ActiveRecord::Migration
  def up
    create_table :offline_records do |t|
      t.integer 'user_id', :null => false
    end

  end

  def down
    drop_table :offline_records
  end
end
