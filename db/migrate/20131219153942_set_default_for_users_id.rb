class SetDefaultForUsersId < ActiveRecord::Migration
  def change
  	drop_table :rooms

  	create_table :rooms do |t|
    	t.integer :users_id, array: true, null: false
    end
  end
end
