class AddWeiboToUsers < ActiveRecord::Migration
  def change
    add_column :users, :weibo, :string
  end
end
