class VoteController < ApplicationController
  def index
    gon.user_info = {}

    if current_user
      gon.user_info = {:loggedIn => true}
      gon.user_info[:id] = current_user.id
      gon.user_info[:username] = current_user.username
      gon.user_info[:room_id] = current_user.room_id if current_user.room_id
      gon.user_info[:group_id] = current_user.group_id if current_user.group_id
      gon.user_info[:round_id] = current_user.round_id if current_user.round_id
      gon.user_info[:total_earning] = current_user.total_earning
      if current_user.group_id
        group = Group.find(current_user.group_id)
        gon.user_info[:group] = {}
        gon.user_info[:group][:round_id] = group.round_id
        gon.user_info[:group][:moneys] = group.moneys
        gon.user_info[:group][:betray_penalty] = group.betray_penalty
        deal = last_deal(group)
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
