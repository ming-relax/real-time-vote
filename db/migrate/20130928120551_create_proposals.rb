class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.integer "group_id"
      t.integer "round_id"
      t.integer "submitter"
      t.integer "acceptor"
      t.boolean "accepted"
      t.integer "submitter_penalty"
      t.integer "acceptor_penalty"
      t.integer "moneys",            array: true
      t.timestamps
    end
  end
end
