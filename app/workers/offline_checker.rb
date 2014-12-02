class OfflineChecker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  # sidekiq_options :retry => false
  recurrence { minutely(1) }
  # def perform(group_id, round_id)
  #   group = Group.find_by_id(group_id)
  #   return if group.round_id != round_id

  #   if group.status == 'deal' and group.acked_users.include?(nil)
  #     offline_users = group.users_id - group.acked_users
  #     group.take_down(offline_users, group.room)
  #   end
  # end

  def perform
    Group.where("status != ?", "dismissed").find_each do |group|
      offline_users = group.users.select {|u| (Time.now - u.updated_at) > 1.minute }
      next if offline_users.count == 0
      first_offline_user = offline_users.sort_by {|u| u.updated_at}.first
      # dismiss this group
      group.users.each do |u|
        u.group_id = nil
        u.room_id = nil
        u.round_id = 0
        u.save!
      end

      room = group.room
      room.users_id = []
      room.save!
      group.status = 'dismissed'

      # create a offline record
      first_offline_user.offline_records.create!(user_id: first_offline_user.id, group_id: group.id, round_id: group.round_id)
    end
  end
end