class Delete < ActiveRecord::Migration
  def change
    drop_table :proposals
    drop_table :groups
  end
end
