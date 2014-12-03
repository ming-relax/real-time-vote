class User < ActiveRecord::Base
  belongs_to :group
  has_many :offline_records
  validates_uniqueness_of :username, :email
  validates_presence_of :email, :weibo
  
  authenticates_with_sorcery!

  # return [user, group_sync, myself_sync ]
  def self.next_round(id)
    user = User.find(id)
    
    if user.round_id < user.group.round_id
      user.round_id += 1 
      user.save!
    end
    

    if Group.round_id_sync?(user.group_id)
      Pusher.group_sync(user.id, user.group_id, user.round_id)
      return [user, true, true]
    else
      return [user, false, true]
    end

  end

  def self.deal_to_earning(users, deal)
    submitter_index = nil
    acceptor_index = nil
    users.each_with_index do |u, index|
      if u.id == deal.submitter
        submitter_index = index
      elsif u.id == deal.acceptor
        acceptor_index = index
      end 
    end

    earning = deal.moneys
    deal.moneys.each_with_index do |m, index|
      if index == submitter_index
        earning[index] -= deal.submitter_penalty
      elsif index == acceptor_index
        earning[index] -= deal.acceptor_penalty
      end
    end
    earning
  end

  def self.query_user(id, group_id, round_id)
    id = id.to_i
    user = User.find(id)
    user.touch
    user_info = {}
    user_info['myself'] = JSON.parse(user.to_json(:only => [:id, :room_id, :total_earning, :username, :round_id]))
    group = user.group
    if group
      user_info["group"] = JSON.parse(group.to_json(:except => [:created_at, :updated_at, :users_id]))
      users = group.users
      user_info["group"]["users"] = users.sort.map { |u| JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) }
      user_info["opponents"] = []
      user_info["group"]["users"].each do |u|
        user_info["opponents"] << { "username" => u['username'], "id" => u['id'] } if u['id'] != id
      end
      if group.status == 'deal'
        # current deal and acked_users
        deal = Proposal.deal(group.id, group.round_id)
        raise "no_deal" unless deal

        user_info["group"]["deal"] = deal

        # covert deal to last earning

        user_info["group"]["last_earning"] = deal_to_earning(users, deal)
      else
        previous_deal = Proposal.previous_deal(group.id, group.round_id)
        user_info["group"]["last_earning"] = deal_to_earning(users, previous_deal) if previous_deal
      end

      Proposal.to_me(group, id).each_with_index do |p, idx|
        if p 
          user_info["opponents"][idx]['proposal_to_me'] = p
        else
          user_info["opponents"][idx]['proposal_to_me'] = nil
        end
      end
    elsif group_id and round_id
      # this group is dismissed, and frontend still send group_id
      offline_record = OfflineRecord.where("user_id = ? AND group_id = ? AND round_id = ?", user.id, group_id, round_id)
      if offline_record.empty?
        user_info['myself']['dismissed'] = true
      else
        user_info['myself']['offline'] = true
      end
    end
    user_info
  end

  def admin?
    admin == true
  end

  def add_admin
    self.admin = true
    self.save!
  end

end
