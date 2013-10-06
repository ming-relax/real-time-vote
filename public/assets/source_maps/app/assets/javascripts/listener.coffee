class App.Listener
  constructor: ->

    @listenTo App.Vent, "user:logged_in", @login

    @sock = new SockJS('http://vote.huming.me:5001');
    @sock.onopen = ->
      console.log 'OPEN'

    @sock.onclose = ->
      console.log 'CLOSED'

    @sock.onmessage = (e) =>
      msg = $.parseJSON e.data
      switch msg.channel
        when 'global:join' then @global_join msg.room_id, msg.user_id, msg.username
        
        when 'global:leave' then @global_leave msg.room_id, msg.user_id
        
        when 'room:join' then @room_join msg.room_id, msg.user_id, msg.username
        
        when 'room:leave' then @room_leave msg.room_id, msg.user_id

        when 'group:start' then @group_start msg.room_id, msg.user_id, msg.group_id, msg.group_info

        when 'group:proposal' then @group_proposal msg.group_id, msg.proposal

        when 'group:deal' then @group_deal msg.group_id, msg.proposal, msg.group_moneys

        when 'group:sync' then @group_sync msg.user_id, msg.group_id, msg.round_id

        else -> console.log 'unkonw channel'

  login: ->
    # console.log 'listener: login'

  isntMyself: (user_id) ->
    current_user_id = App.currentUser.id
    return user_id and user_id isnt current_user_id

  isMyself: (user_id) ->
    current_user_id = App.currentUser.id
    return current_user_id && current_user_id is user_id

  isMyGroup: (group_id) ->

    current_group_id = App.currentUser.group_id()
    return current_group_id && group_id && current_group_id is group_id

  isMyRoom: (room_id) ->
    current_room_id = App.currentUser.get 'room_id'
    return current_room_id is room_id

  isOtherPlayer: (room_id, user_id) ->
    current_room_id = App.currentUser.get 'room_id'
    current_user_id = App.currentUser.id
    return user_id isnt current_user_id and room_id is current_room_id

  # room_id is not my room_id
  global_join: (room_id, user_id, username) -> 
    if @isntMyself(user_id) and !@isMyRoom(room_id)
      console.log "global:join room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}" 
      App.Vent.trigger "push:global:join", room_id, user_id, username

  # room_id is not my room_id
  global_leave: (room_id, user_id) ->
    if @isntMyself(user_id) and !@isMyRoom(room_id)
      console.log "global:leave room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
      App.Vent.trigger 'push:global:leave', room_id, user_id


  room_join: (room_id, user_id, username) ->
    if @isOtherPlayer room_id, user_id
      console.log "room:join room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
      App.Vent.trigger 'push:room:join', room_id, user_id, username

  room_leave: (room_id, user_id) ->
    if @isOtherPlayer room_id, user_id
      console.log "room:leave room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
      App.Vent.trigger 'push:room:leave', room_id, user_id

  # when the msg pushed user may not get rooms' response
  group_start: (room_id, user_id, group_id, group_info) ->
    if @isMyRoom(room_id) and @isntMyself(user_id)
      console.log "group:start room_id: #{room_id} group_id: #{group_id}, current_user: #{App.currentUser.id}, group_info: #{group_info}"
      App.currentUser.set_group(group_info)
      App.currentUser.set 'round_id', 0
      App.currentUser.set 'group_id', group_info.id
      App.Vent.trigger 'group:start'

  group_proposal: (group_id, proposal) ->
    
    if @isMyself(proposal.acceptor)
      console.log "group:proposal group_id: #{group_id}, proposal: ", proposal
      App.Vent.trigger 'push:group:proposal', group_id, proposal

  group_deal: (group_id, deal, group_moneys) ->
    if @isMyGroup(group_id) and @isntMyself(deal.acceptor)
      console.log "group:deal group_id: #{group_id}, deal: ", deal
      App.Vent.trigger 'push:group:deal', group_id, deal, group_moneys

  group_sync: (user_id, group_id, round_id) ->
    console.log "group:sync group_id: #{group_id}, round_id: #{round_id}" 
    if @isntMyself(user_id) && @isMyGroup(group_id)
      App.Vent.trigger 'push:group:sync', round_id

_.extend App.Listener.prototype, Backbone.Events
