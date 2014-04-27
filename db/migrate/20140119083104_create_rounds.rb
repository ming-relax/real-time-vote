class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.belongs_to :group
      t.integer :round_id
      t.string :status
      t.timestamps
    end
  end
end
