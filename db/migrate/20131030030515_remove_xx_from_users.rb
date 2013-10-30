class RemoveXxFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :xx
  end
end
