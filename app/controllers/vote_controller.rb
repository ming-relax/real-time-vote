class VoteController < ApplicationController
  def index
    gon.user_info = current_user
  end
end
