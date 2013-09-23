class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # protect_from_forgery with: :reset_session
  respond_to :json

  private
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
end
