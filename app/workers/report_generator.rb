require 'csv'
class ReportGenerator
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(10) }

  def perform
    attrs = User.attribute_names
    attrs.select! {|a| ['crypted_password', 'salt', 'admin', 'created_at', 'updated_at'].include?(a) == false}
    CSV.open("public/users.csv", "wb") do |csv|
      csv << attrs
      User.find_each do |u|
        row = attrs.map do |a|
          u["#{a}"]
        end
        csv << row
      end
    end

    attrs = Group.attribute_names
    attrs.select! {|a| ['id', 'room_id', 'round_id', 'betray_penalty'].include?(a) == true}
    CSV.open("public/groups.csv", "wb") do |csv|
      attrs = attrs + ['user-1', 'user-2', 'user-3']
      attrs = attrs + ['money-1', 'money-2', 'money-3']
      csv << attrs
      Group.find_each do |group|
        row = attrs.map do |a|
          if group["#{a}"]
            group["#{a}"]
          elsif a.include? 'user'
            idx = a.split('-').last.to_i - 1
            group.users_id[idx].to_s
          elsif a.include? 'money'
            idx = a.split('-').last.to_i - 1
            u_id = group.users_id[idx].to_s
            group.moneys["#{u_id}"]
          end
        end
        csv << row
      end
    end

    attrs = Proposal.attribute_names
    attrs.select! {|a| ['id', 'group_id', 'round_id', 'submitter', 'acceptor', 'submitter_penalty', 'acceptor_penalty'].include?(a) == true}
    CSV.open("public/proposals.csv", "wb") do |csv|
      attrs = attrs + ['user-1', 'user-2', 'user-3']
      attrs = attrs + ['money-1', 'money-2', 'money-3']
      csv << attrs
      Proposal.find_each do |proposal|
        row = attrs.map do |a|
          if proposal["#{a}"]
            proposal["#{a}"]
          end
        end
        # fill in the last 6 columns
        row[-6..-4] = proposal.moneys.keys
        row[-3..-1] = row[-6..-4].map {|x| proposal.moneys["#{x}"]}
        csv << row
      end
    end

    attrs = OfflineRecord.attribute_names
    CSV.open("public/offline_records.csv", "wb") do |csv|
      csv << attrs
      OfflineRecord.find_each do |offline_record|
        row = attrs.map do |a|
            offline_record["#{a}"]
        end
        csv << row
      end
    end

  end
end