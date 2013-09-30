# A Realtime Game：
####http://vote.huming.me


## Functionality      
   
   This is a multi-player relatime game. Users can choose a room; the game starts when the room is full of three people. In this game, user can submit proposal to opponents and accept proposal from opponents; and all this happens in realtime. Proposals will be pushed to opponents. 


## System Components
![alt text][logo]
[logo]: ./arch.png

   Node.js: responsible for push message initiated by user action
   
   Rails + Backbone.js: business logic 
   
   Redis: pub/sub service and caching
    	
	
## Design Principle

###0) all events should be handled by Backbone.Views; including UI event and custom defined events

###1) the one who initiate **push** should not process the **push** message


###2) http response should have all info as if were **pushed** from node.js


###3) every browser refresh should get fresh data (kind of like init system state), in case of error happens or user want to fresh.	



## Protocols

### Node.js ---> Browser 
   
   
   |            Type         |       Message     |      Description    |
   | ------------------------|:-----------------:| -------------------:|
   | Global: Join | room_id | One user enters a room|
   | Global: Leave| room_id | One user leaves a room|
   | Room: Join   | user_id | User joined my room|
   | Room: Leave  | user_id | Opponent leaves|
   | Group: Start  | room_id, group_id, round_id | start game|
   | Group: Proposal | user_id, proposal | proposal submitted|
   | Group: Decision | proposal | A deal was made |
   | Group: NextRound| True | Ready to start next round | 
   
   
### Browser ---> Rails


   | Resources | Action | Parameter | Description|
   | ----------|:------:| -----------:| ----------:|
   | rooms | UPDATE |  room_id, user_id, **join** | function: join_room|
   | rooms | UPDATE | room_id, user_id, **leave** | function: leave_room 
   | rooms | UPDATE | room_id, user_id, **next_round_id**| function: update_round |
   |proposals|CREATE|proposal| function:create_proopsal|
   |proposals|UPDATE|proposal, **accept**|function:accept_proposal|
   
####function RAILS#room#join_room:
	 
	 if 房间满了
	 	return nil
	 end
	 
	 get a empty seat;
	 
	 PUBLISH Global:Join
	 PBULISH Room: Join
	 
	 if 房间满了 (需添加分布式锁)
	   if 用户group_id存在，并且和组内其他人一样
	   	PUBLISH Room:Rejoin;
	   	return;
	   end
	   
	   <!--当前用户gorup_id与其他人不一样，或者没有group_id-->
	 	err = creat a group;
	 	if err
	 		PUBLISH Error:GroupCreate
	 		return nil
	 	end
	 	group.round_id = 0
	 	users.each do
	 		u.group_id = group.id
	 		err = u.save
	 		if err
	 			PUBLISH Error:UserGroupInit
	 			return nil
	 		end
	 	end
	 	
	 	PUBLISH Room:Start
	 	
	 	
####function RAILS#room#leave_room:
	
	PUBLISH Global: Leave;
	PUBLISH Room: Leave
   
####function RAILS#room#update_round:
  
	if 当前用户round_id == room内其它其它用户round_id
		PUBLISH Room:NextRound;
		return room_info;
	end
	return nil;
		

####function RAILS#create_proposal:
		
	提交新的proposal，若成功，Room: Proposal
	err = create_proposal;
	if err
		return nil
	end
	PUBLISH Room: Proposal
	return proposal;
   

####function RAILS#accept_proposal:

	if decision has made:
		return nil;
	end
	
	err = update_proposal(accept:true);
	if err
		return nil;
	end
	PUBLISH Room:Decision
	return proposal;
   
   
####function NODE#handle_connect
	1) 新用户加入一个room 

####function NODE#handle_close


##Node.js 

Redis的两个用途：

    1）pub/sub 实现Node.js向client推送消息
    2）数据缓存
###Redis
	 1）利用 Redis 的 pub/sub 实现 Rails 向 client 的消息推送；其中 Node.js 只管理连接的建立、关闭，不保存任何状态。
	 2）缓存。

    "rooms:id"  => {:users => [x_id, y_id, z_id]}     [JSON string]
    
    "groups:id" => "{id: xx, room_id: xx, round_id: xx, group_money: xx[3]}"
    "users:id"  => "{id: xx, room_id: xx, group_id: xx, total_earning: xx, online: false}"  [hash]

    accepted_proposal
    
###Postgres
users:
	
	id, room_id, group_id, total_earning


groups

	id, room_id, round_id, moneys[3]
	
	 
proposals

	id, submitter, acceptor, moneys[3], accepted?, submitter_penaty, acceptor_penalty, group_id, round_id
	
	


###4) senario to consider:
      join room;
      form a group;
      accept proposal and make a deal;
      start next round;
