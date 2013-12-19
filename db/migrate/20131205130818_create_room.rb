class CreateRoom < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
    	t.integer "user_id", array: true
    end
  end
end
