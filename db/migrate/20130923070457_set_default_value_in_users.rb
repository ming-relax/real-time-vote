class SetDefaultValueInUsers < ActiveRecord::Migration
  def change
    change_column :users, :total_earning, :integer, :default => 0
    change_column :groups, :betray_penalty, :integer, :default => 0
  end
end
