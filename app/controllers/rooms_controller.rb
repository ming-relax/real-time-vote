class RoomsController < ApplicationController
  
  def index
    @rooms = []
    40.times do |i|
    @rooms << {:id => i, :users => Room.get_users(i) }
    end  
    respond_with(@rooms)
  end

  def update
    if (!params[:user_id] || !params[:id])
      render status:422
      return false
    end

    user_id = params[:user_id].to_i
    room_id = params[:id].to_i
    
    if params[:join] == true
      err, @users = Room.join(room_id, user_id)
      render status:422 if err
    else
      err, @users = Room.leave(room_id, user_id)
      render status:422 if err
    end
  end

  private



end
