class User < ActiveRecord::Base
  belongs_to :group
  authenticates_with_sorcery!

  # return round_id if synced
  def self.next_round(id)
    user = User.find(id)
    
    if user.round_id < user.group.round_id
      user.round_id += 1 
      user.save!
    end
    

    if Group.round_id_sync?(user.group_id)
      Pusher.group_sync(user.id, user.group_id, user.round_id)
      return [user, true]
    else
      return [user, false]
    end

  end

end
