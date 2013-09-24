class Room
  def self.get_users(i)
    room = JSON.parse($redis.get("rooms:#{i}"))
    room['users']
  end

  def self.set_users(room_id, users)
    $redis.set("rooms:#{room_id}", {:users => users}.to_json)
  end

  def self.join(room_id, user_id)
    users = get_users(room_id)
    if users.length == 3
      return ['room is full', users]
    end

    users = users.to_set()
    users.add(user_id)
    users = users.to_a

    # update redis
    set_users(room_id, users)

    # update pg
    u  = User.find(user_id)
    u.room_id = room_id
    u.save!

    # Push message
    Pusher.join(room_id, user_id)
    g_id = -1
    if users.length == 3
      # create group and push start msg to group members
      g = Group.create(room_id: room_id, 
                       round_id: 0, 
                       moneys: [0, 0, 0],
                       betray_penalty: Group.betray_penalty())
      g_id = g.id
      group_users = []
      users.each do |u_id|
        u = User.find(u_id)
        u.group_id = g.id
        u.round_id = 0
        u.save!
        group_users << u.id
      end

      Pusher.start(room_id, g.id, group_users)
    end

    [nil, users, g_id]
  end

  def self.leave(room_id, user_id)
    users = get_users(room_id)
    users.select! {|u| u != user_id}
    
    # update redis
    set_users(room_id, users)

    # update pg
    u = User.find(user_id)
    u.room_id = nil
    u.save!

    # Push message
    Pusher.leave(room_id, user_id)

    [nil, users]
  end
end


