class RenameRoundId < ActiveRecord::Migration
  def change
    rename_column :rounds, :round_id, :deal_count
  end
end
