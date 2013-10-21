class AddXxToUsers < ActiveRecord::Migration
  def change
    add_column :users, :xx, :integer
  end
end
