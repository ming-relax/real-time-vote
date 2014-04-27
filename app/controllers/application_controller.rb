class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  respond_to :json

  private

    def init_user_info
      user_info = {}
      user_info[:id] = current_user.id
      user_info
    end

    def current_group
      group_id = current_user.group_id
      return nil unless group_id
      Group.find(group_id)
    end

    def last_deal(user)
      return nil if user.round_id == 0
      Proposal.where('group_id = ? AND round_id = ? AND accepted = ?',
                      user.group_id, user.round_id - 1, true).first

    end

    def current_deal(user)
      return nil if user.round_id == nil
      Proposal.where('group_id = ? AND round_id = ? AND accepted = ?',
                      user.group_id, user.round_id, true).first

    end

    def group_users
      group_id = current_user.group_id
      return nil unless group_id

      group = Group.find group_id
      users = group.users
      u = []
      users.each do |x|
        u << x.id
      end
      u
    end

  helper_method :group_users
  helper_method :current_group
  helper_method :last_deal
  helper_method :init_user_info
end
