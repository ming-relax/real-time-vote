class RoomsController < ApplicationController
  
  def index
    @rooms = Room.all.sort
  end

  def join
    room_id = params[:room_id].to_i
    user_id = params[:user_id].to_i
    begin
      @user = Room.join(room_id, user_id)
    rescue RoomError => e
      render :json => {:errors => e.message}, :status => 424
    end
  end

  def leave
    room_id = params[:room_id].to_i
    user_id = params[:user_id].to_i
    begin
      @users, @group_id = Room.leave(room_id, user_id)
    rescue RoomError => e
      puts e.message
      render :json => {:errors => e.message}, :status => 424
    end
    
  end

end
