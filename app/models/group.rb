class Group < ActiveRecord::Base
  # status: 'active' -> 'deal', 'dismissed'
  belongs_to :room
  has_many :proposals
  has_many :users

  def self.generate_penalty
    [20, 40, 60].sample
    # 20
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

  # return this round's final moneys
  def update_users_earnings(p)
    submitter_penalty = 0
    acceptor_penalty = 0

    users = (0..2).map do |i|
      User.find(self.users_id[i])
    end
    users = users.sort { |a, b| a.id <=> b.id }
    users_moneys = Hash[users.map {|u| [u.id.to_s, 0]}]
    users.each_with_index do |user, i|
      # puts "*" * 80
      # puts p.moneys
      # puts p.moneys[user.id.to_s]
      # puts users[i].total_earning
      users[i].total_earning += p.moneys[user.id.to_s]
      users_moneys[user.id.to_s] = p.moneys[user.id.to_s]

      if users[i].id == p.acceptor
        acceptor_penalty = penalty(p.acceptor, p.submitter, p.round_id)
        users[i].total_earning -= acceptor_penalty
        users_moneys[user.id.to_s] -= acceptor_penalty
        # puts "acceptor_penalty: #{acceptor_penalty}, id: #{p.acceptor}, index: #{i}"
      end

      if users[i].id == p.submitter
        submitter_penalty = penalty(p.submitter, p.acceptor, p.round_id)
        users[i].total_earning -= submitter_penalty
        users_moneys[user.id.to_s] -= submitter_penalty
        # puts "submitter_penaly: #{submitter_penalty}, id: #{p.submitter}, index: #{i}"
      end
      users[i].save!
    end
    # puts "update_users_earnings: #{users_moneys}"

    [submitter_penalty, acceptor_penalty, users_moneys]

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
      # Change user's round id first
      # If all users are acked, change group's round id
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

  def take_down(offline_users_id, room)
    self.with_lock do
      self.users.each do |user|
        # create offline record for those users
        if offline_users_id.include?(user.id)
          user.offline_records.create!(user_id: user.id, group_id: user.group.id, round_id: user.round_id)
        end
        user.group_id = nil
        user.room_id = nil
        user.save!
      end
      offline_users_id.each do |id|
        u = User.find(id)
        u.group_id = nil
        u.room_id = nil
        u.save!
      end
      room.users_id = []
      room.save!
    end
  end

end
