# 在线实时游戏设计：
## 功能描述   
   
   多个玩家使用的在线游戏。用户登录系统后，可选择一个还有剩余座位的房间，一旦房间人数达到设定值，便开始游戏。玩家可以提出提案，接受提案，开始下一轮游戏。在游戏的过程中，玩家可以中途退出。


## 系统架构
![alt text][logo]
[logo]: ./arch.png
    	
## Use Cases

###1. Join a Room


	玩家进入一个有空闲位置的房间
	
	

## 协议

### Server ---> Client 
   
   
   |            Type         |       Message     |      Description    |
   | ------------------------|:-----------------:| -------------------:|
   | Global: Join | room_id | 某人进入了某一个房间，用于更新房间内的空余座位数量|
   | Global: Leave| room_id | 某人离开了某一个房间，用于更新房间内的额空余座位数量|
   | Room: Join   | user_id | 其他人加入了当前用户所在的房间，用于告知当前用户的对手的信息|
   | Room: Leave  | user_id | 对手离开了这个房间，有可能是对手掉线，也有可能是对手加入了其它房间 |
   | **Room: Rejoins**| user_id |用户重新加入了该组，原因是用户刚刚暂时掉线了|
   | Group: Start  | room_id, group_id, round_id | 人数齐了，可以开始游戏了|
   | Group: Proposal | user_id, proposal | 对手提交了一个 proposal |
   | Group: Decision | proposal | 有两个人达成了交易 |
   | Group: NextRound| True | 全部确认了，可以开始下一轮游戏了 | 
   
   
### Client ---> Server


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


##Data Model
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

