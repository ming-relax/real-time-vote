class CreateGroupsProposals < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :room_id
      t.integer :round_id
      t.integer :betray_penalty
      t.integer :moneys, array: true
    end

    create_table :proposals do |t|
      t.integer :group_id
      t.integer :round_id
      t.integer :submitter
      t.integer :acceptor
      t.integer :moneys, array: true
      t.boolean :accepted
      t.integer :submitter_penalty
      t.integer :acceptor_penalty

    end
  end
end
