class User < ActiveRecord::Base
  belongs_to :group
  validates_uniqueness_of :username
  
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

  def self.query_user(id)
    user = User.find(id)
    user_info = {}
    user_info['myself'] = JSON.parse(user.to_json(:only => [:id, :room_id, :total_earning, :username, :round_id]))
    group = user.group
    if group
      user_info["group"] = JSON.parse(group.to_json(:except => [:created_at, :updated_at, :users_id]))
      users = group.users
      user_info["group"]["users"] = users.map { |u| JSON.parse(u.to_json(:only => [:id, :username, :total_earning])) }
      user_info["opponents"] = []
      user_info["group"]["users"].each do |u|
        user_info["opponents"] << { "username" => u['username'], "id" => u['id'] } if u['id'] != id
      end
      if group.status == 'deal'
        # current deal and acked_users
        deal = Proposal.deal(group.id, group.round_id)
        raise "no_deal" unless deal

        user_info["group"]["deal"] = deal
      end

      Proposal.to_me(group, id).each_with_index do |p, idx|
        if p 
          user_info["opponents"][idx]['proposal_to_me'] = p
        else
          user_info["opponents"][idx]['proposal_to_me'] = nil
        end
      end
    end
    user_info
  end

end
