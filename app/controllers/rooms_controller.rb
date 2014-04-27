class RoomsController < ApplicationController
  
  def index
    @rooms = Room.all.sort
  end

  def join
    room_id = params[:room_id].to_i
    user_id = params[:user_id].to_i
    begin
      @users, @group_info = Room.join(room_id, user_id)
      # Pusher.room_list()
      # Pusher.group_start(room_id, user_id, @group_info) if @group_info
    rescue RoomError => e
      render :json => {:errors => e.message}, :status => 424
    end
       
  end

  def leave
    room_id = params[:room_id].to_i
    user_id = params[:user_id].to_i
    begin
      @users, @group_id = Room.leave(room_id, user_id)
      # Pusher.room_list()
      # Pusher.group_stop(room_id, @group_id) if @group_id
    rescue RoomError => e
      puts e.message
      render :json => {:errors => e.message}, :status => 424
    end
    
  end

end
