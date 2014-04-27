class ChangeDefaultGroupStatus < ActiveRecord::Migration
  def change
  	remove_column :groups, :status
  	add_column :groups, :status, :string, :default => "active"
  end
end
