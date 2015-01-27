class Room < ActiveRecord::Base
  has_many :groups
  def self.join(room_id, user_id)
    self.transaction do
      user = User.find(user_id)
      delete_user(user.room_id, user.id) if user.room_id
      users = add_user(room_id, user_id)

      group_info = nil
      if users.length == 3
        # create group and push start msg to group members
        g = Group.create(room_id: room_id, 
                         round_id: 0, 
                         moneys: {"#{users[0]}" => 0, "#{users[1]}" => 0, "#{users[2]}" => 0},
                         users_id: [users[0], users[1], users[2]],
                         acked_users: [nil, nil, nil],
                         betray_penalty: Group.generate_penalty())
        group_info = {}
        group_info[:id] = g.id
        group_info[:users] = []

        users.each do |u_id|
          user = User.find(u_id)
          user.group_id = g.id
          user.round_id = 0
          user.save!
          group_info[:users] << {:id => user.id, :username => user.username }
        end

        group_info[:round_id] = g.round_id
        group_info[:moneys] = g.moneys
        group_info[:betray_penalty] = g.betray_penalty
      end

      # [users, group_info]
      user.reload
    end

  end

  def self.leave(room_id, user_id)
    self.transaction do
      users = delete_user(room_id, user_id)

      # Push message
      Pusher.leave(room_id, user_id)
      users   
    end
  end

  
  def self.add_user(room_id, user_id)
    r = Room.lock(true).find_by_id(room_id)
    raise RoomError, 'RoomNotFound' if r == nil

    raise RoomError, 'RoomFull' if r.users_id.length == 3

    r.users_id << user_id
    r.users_id = r.users_id.to_set.to_a
    r.users_id_will_change!
    r.save!

    u = User.find(user_id)
    u.room_id = r.id
    u.save!

    r.users_id
  end

  def self.delete_user(room_id, user_id)
    group_id = nil
    r = Room.lock(true).find_by_id(room_id)
    raise RoomError, 'RoomNotFound' if r == nil

    raise RoomError, 'RoomEmpty' if r.users_id.length == 0
    
    # change user/group
    u = User.find_by_id(user_id)
    raise RoomError, 'RoomNullUser' unless u

    u.room_id = nil
    if u.group_id
      # preserve it for return value
      group_id = u.group_id
      u.group.status = 'destroyed'
      u.group.save!
      u.group_id = nil
    end
    u.save!

    # change room
    new_users = r.users_id.select {|u| u != user_id}
    
    # delete a user don't belong here
    raise RoomError, 'RoomNullUser' if new_users == r.users_id

    r.users_id = new_users
    r.users_id_will_change!
    r.save!
    [r.users_id, group_id]
  end

end