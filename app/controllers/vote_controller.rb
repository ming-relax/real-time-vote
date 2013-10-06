class VoteController < ApplicationController
  def index
    gon.user_info = {}
    gon.env = Rails.env
    if current_user
      gon.user_info = {:loggedIn => true}
      gon.user_info[:id] = current_user.id
      gon.user_info[:username] = current_user.username
      gon.user_info[:room_id] = current_user.room_id if current_user.room_id
      gon.user_info[:round_id] = current_user.round_id if current_user.round_id
      gon.user_info[:total_earning] = current_user.total_earning
      gon.user_info[:is_group_sync] = true
      gon.user_info[:is_myself_sync] = true
      if current_user.group_id
        if Group.round_id_sync?(current_user.group_id)
          gon.user_info[:is_group_sync] = true
        else
          gon.user_info[:is_group_sync] = false
        end

        gon.user_info[:group] = {}
        # fill in group members info
        # should use Redis 
        group = Group.find(current_user.group_id)

        if group.round_id == current_user.round_id
          gon.user_info[:is_myself_sync] = true
        else
          gon.user_info[:is_myself_sync] = false
        end

        users = group.users.sort! {|a, b| a.id <=> b.id }
        gon.user_info[:group][:id] = group.id
        gon.user_info[:group][:users] = []
        users.each do |u|
          gon.user_info[:group][:users] << {:id => u.id, :username => u.username}
        end
       
        gon.user_info[:group][:round_id] = group.round_id
        gon.user_info[:group][:moneys] = group.moneys
        gon.user_info[:group][:betray_penalty] = group.betray_penalty

        deal = current_deal(current_user)
        if deal
          gon.user_info[:group][:current_deal] = {}
          gon.user_info[:group][:current_deal][:submitter] = deal.submitter
          gon.user_info[:group][:current_deal][:acceptor] = deal.acceptor
          gon.user_info[:group][:current_deal][:moneys] = deal.moneys
          gon.user_info[:group][:current_deal][:submitter_penalty] = deal.submitter_penalty
          gon.user_info[:group][:current_deal][:acceptor_penalty] = deal.acceptor_penalty
        end
        deal = last_deal(current_user)
        if deal
          gon.user_info[:group][:last_deal] = {}
          gon.user_info[:group][:last_deal][:submitter] = deal.submitter
          gon.user_info[:group][:last_deal][:acceptor] = deal.acceptor
          gon.user_info[:group][:last_deal][:moneys] = deal.moneys
          gon.user_info[:group][:last_deal][:submitter_penalty] = deal.submitter_penalty
          gon.user_info[:group][:last_deal][:acceptor_penalty] = deal.acceptor_penalty
        end
      end
    else
      gon.user_info = {:loggedIn => false}
    end
  end
end
