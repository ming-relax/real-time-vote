class OfflineChecker
  include Sidekiq::Worker

  def perform(group_id, round_id)
    group = Group.find_by_id(group_id)
    return if group.round_id != round_id

    if group.status == 'deal' and group.acked_users.include?(nil)
      offline_users = group.users_id - group.acked_users
      group.take_down(offline_users, group.room)
    end
  end
end