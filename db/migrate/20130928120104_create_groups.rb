class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer "room_id"
      t.integer "round_id"
      t.integer "betray_penalty"
      t.integer "moneys",         array: true
      t.timestamps
    end
  end
end
