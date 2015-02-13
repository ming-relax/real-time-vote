class AddRoundIdBack < ActiveRecord::Migration
  def change
    add_column :users, :round_id, :integer
  end
end
