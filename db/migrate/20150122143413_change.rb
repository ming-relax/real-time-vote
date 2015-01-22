class Change < ActiveRecord::Migration
  def up
    remove_column :groups, :moneys
    add_column :groups, :moneys, :json
    remove_column :proposals, :moneys
    add_column :proposals, :moneys, :json
  end

  def down
    remove_column :groups, :moneys
    add_column :groups, :moneys, :array
    remove_column :proposals, :moneys
    add_column :proposals, :moneys, :array
  end

end
