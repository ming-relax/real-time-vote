class Group < ActiveRecord::Base
  # status: 'active' -> 'deal'
  belongs_to :room
  has_many :proposals
  has_many :users
    
  def self.generate_penalty
    [0, 10, 20].sample
  end

  # use redis to cache group info
  def self.round_id_sync?(group_id)
    group = Group.find(group_id)
    users = group.users
    users.each do |u|
      return false if u.round_id != group.round_id
    end
    return true
  end

  def penalty(this_id, other_id, round_id)
    return 0 if round_id == 0

    last_round = round_id - 1
    last_decision = Proposal.where(group_id: self.id, round_id: last_round, accepted: true).first
    if (!last_decision)
      raise 'Not possible'
    end

    if (last_decision.submitter == this_id && last_decision.acceptor != other_id)
      return self.betray_penalty
    end

    if (last_decision.acceptor == this_id && last_decision.submitter != other_id)
      return self.betray_penalty
    end

    return 0


  end

  def update_earnings(p)
    submitter_penalty = 0
    acceptor_penalty = 0

    users = (0..2).map do |i|
      User.find(self.users_id[i])
    end
    users = users.sort { |a, b| a.id <=> b.id }

    moneys = [0, 0, 0]
    users.each_index do |i|
      users[i].total_earning += p.moneys[i]
      moneys[i] = p.moneys[i]

      if users[i].id == p.acceptor
        acceptor_penalty = penalty(p.acceptor, p.submitter, p.round_id)
        users[i].total_earning -= acceptor_penalty
        moneys[i] -= acceptor_penalty
        # puts "acceptor_penalty: #{acceptor_penalty}, id: #{p.acceptor}, index: #{i}"
      end

      if users[i].id == p.submitter
        submitter_penalty = penalty(p.submitter, p.acceptor, p.round_id)
        users[i].total_earning -= submitter_penalty
        moneys[i] -= submitter_penalty
        # puts "submitter_penaly: #{submitter_penalty}, id: #{p.submitter}, index: #{i}"
      end

      users[i].save!
      
    end
    
    # puts "update_earnings: #{moneys}"

    [submitter_penalty, acceptor_penalty, moneys]

  end


  def self.exit_group(group_id, user_id)
    self.transaction do
      group = Group.find(group_id)
      users = group.users
      users.each do |u|
       u.group_id = nil
       Room.leave(u.room_id, u.id) if u.id == user_id
       u.save! 
      end
    end
  end

  def next_round(user_id)
    self.with_lock do
      user_index = users_id.index(user_id)
      raise 'InvalidUserId' unless user_index
      self.acked_users[user_index] = user_id
      if self.acked_users == self.users_id
        self.status = 'active'
        self.round_id += 1
        self.acked_users = [nil, nil, nil]
      end
      self.acked_users_will_change!
      self.save!
    end
  end

end
