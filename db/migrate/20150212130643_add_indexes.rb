class AddIndexes < ActiveRecord::Migration
  def up
    add_index :users, :username
    add_index :users, :email
    add_index :users, :room_id
    add_index :users, :group_id

    add_index :groups, :room_id
    add_index :groups, :round_id
    add_index :groups, :status

    add_index :proposals, :group_id
    add_index :proposals, :submitter
    add_index :proposals, :acceptor
    add_index :proposals, :accepted

  end

  def down
    remove_index :users, :username
    remove_index :users, :email
    remove_index :users, :room_id
    remove_index :users, :group_id

    remove_index :groups, :room_id
    remove_index :groups, :round_id
    remove_index :groups, :status

    remove_index :proposals, :group_id
    remove_index :proposals, :submitter
    remove_index :proposals, :acceptor
    remove_index :proposals, :accepted
  end
end
