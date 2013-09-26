class Pusher

  def self.join(room_id, user_id, username)
    publish "global:join", {:room_id => room_id, 
                            :user_id => user_id,
                            :username => username }
    publish "room:join", {:room_id => room_id, 
                          :user_id => user_id,
                          :username => username}
  end

  def self.leave(room_id, user_id)
    publish "global:leave", {:room_id => room_id, :user_id => user_id }
    publish "room:leave", {:room_id => room_id, :user_id => user_id }
  end

  def self.start(room_id, user_id, group_id, group_info)
    publish "group:start", {:room_id => room_id,
                            :user_id => user_id,
                            :group_id => group_id, 
                            :group_info => group_info }
  end

  def self.proposal(p)
    publish("group:proposal",
            { :group_id => p.group_id, 
              :proposal => {:id => p.id, 
                            :group_id => p.group_id, 
                            :round_id => p.round_id,
                            :submitter => p.submitter,
                            :acceptor => p.acceptor,
                            :moneys => p.moneys,
                            :accepted => p.accepted}})
  end


  def self.deal(p)

    publish("group:deal",
            { :group_id => p.group_id, 
              :proposal => {:id => p.id, 
                            :group_id => p.group_id, 
                            :round_id => p.round_id,
                            :submitter => p.submitter,
                            :acceptor => p.acceptor,
                            :moneys => p.moneys,
                            :accepted => p.accepted,
                            :submitter_penalty => p.submitter_penalty,
                            :acceptor_penalty => p.acceptor_penalty}})
  end


  def self.group_sync(user_id, group_id, round_id)
    publish("group:sync",
            { :user_id => user_id,
              :group_id => group_id,
              :round_id => round_id})
  end

  def self.publish(channel, msg)
    $redis.publish channel, JSON.dump(msg)
  end

end