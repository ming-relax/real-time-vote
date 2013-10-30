class Room
  def self.get_users(i)
    room = JSON.parse($redis.get("rooms:#{i}"))
    room['users']
  end
  # key:    "rooms:#{room_id}"
  # value:  users: [{user_id: xx, username: xx}, ..]
  def self.set_users(room_id, users)
    $redis.set("rooms:#{room_id}", {:users => users}.to_json)
  end

  def self.add_user(room_id, user_id, username)
    users = get_users(room_id)
    return ['full', users] if users.length == 3

    users.each do |u|
      return ['rejoin', users] if u['user_id'] == user_id
    end

    users << {'user_id' => user_id, 'username' => username}
    users.sort! {|a, b| a['user_id'] <=> b['user_id'] }    
    set_users(room_id, users)

    # update pg
    u = User.find(user_id)
    u.room_id = room_id
    u.save! 
    return [nil, users]
  end


  def self.join(room_id, user_id, username)

    err, users = add_user(room_id, user_id, username)
    return [err, users, nil] if err

    # Push message
    Pusher.join(room_id, user_id, username)

    group_info = nil
    if users.length == 3
      # create group and push start msg to group members
      g = Group.create(room_id: room_id, 
                       round_id: 0, 
                       moneys: [0, 0, 0],
                       users_id: [users[0]['user_id'], users[1]['user_id'], users[2]['user_id']],
                       betray_penalty: Group.generate_penalty())
      group_info = {}
      group_info[:id] = g.id
      group_info[:users] = []

      users.each do |u|
        user = User.find(u['user_id'])
        user.group_id = g.id
        user.round_id = 0
        user.save!
        group_info[:users] << {:id => user.id, :username => user.username }
      end

      group_info[:round_id] = g.round_id
      group_info[:moneys] = g.moneys
      group_info[:betray_penalty] = g.betray_penalty

      Pusher.start(room_id, user_id, g.id, group_info)
    end

    [nil, users, group_info]
  end

  def self.leave(room_id, user_id)
    users = get_users(room_id)

    users.select! do |u|
      u['user_id'] != user_id
    end

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


