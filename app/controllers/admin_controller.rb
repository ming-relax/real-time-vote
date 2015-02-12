class AdminController < ApplicationController
  # before_filter :require_admin

  def index
    render :index, layout: "admin"
  end

  def show_users
    users = User.all.select {|u| u.username != 'admin'}

    assigned_users = users.select {|u| u.group_id != nil }
    assigned_users.sort_by! {|u| u.group_id}

    other_users = users.select {|u| u.group_id == nil }
    other_users.sort_by! {|u| u.id }

    respond_to do |format|
      format.json { 
        render json: assigned_users + other_users
      }
    end
  end

  def show_groups
    groups = Group.all
    respond_to do |format|
      format.json { 
        render json: groups
      }
    end
  end

  def show_proposals
    proposals = Proposal.last(100)
    proposals_hash = []
    proposals.each do |p|
      # p['users'] = p.group.users.sort_by { |x| x.id }
      p_attr = p.attributes.to_hash
      p_attr['users'] = []
      p.group.users_id.each do |u_id|
        u = User.find(u_id)
        p_attr['users'] << u
      end

      p_attr['users'].sort_by! { |x| x.id }

      proposals_hash << p_attr
    end

    respond_to do |format|
      format.json {
        render json: proposals_hash
      }
    end
  end

  def show_offline_records
    @records = OfflineRecord.order("created_at DESC").limit(100)
  end

end
