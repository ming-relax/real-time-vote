class App.Listener
  constructor: ->

    @listenTo App.Vent, "user:logged_in", @login

    @sock = new SockJS('http://0.0.0.0:5001');
    @sock.onopen = ->
      console.log 'OPEN'

    @sock.onclose = ->
      console.log 'CLOSED'

    @sock.onmessage = (e) =>
      msg = $.parseJSON e.data
      switch msg.channel
        when 'global:join' then @global_join msg.room_id, msg.user_id
        
        when 'global:leave' then @global_leave msg.room_id, msg.user_id
        
        when 'room:join' then @room_join msg.room_id, msg.user_id
        
        when 'room:leave' then @room_leave msg.room_id, msg.user_id

        when 'group:start' then @group_start msg.room_id, msg.group_id, msg.group_users

        when 'group:proposal' then @group_proposal msg.group_id, msg.proposal

        when 'group:deal' then @group_deal msg.group_id, msg.proposal

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
    current_group_id = App.currentUser.get 'group_id'
    return current_group_id && group_id && current_group_id is group_id

  isOtherPlayer: (room_id, user_id) ->
    current_room_id = App.currentUser.get 'room_id'
    current_user_id = App.currentUser.id
    return user_id and user_id isnt current_user_id and room_id and room_id is current_room_id

  global_join: (room_id, user_id) -> 
    console.log "global:join room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
    if @isntMyself user_id      
      App.Vent.trigger "push:global:join", room_id, user_id

  global_leave: (room_id, user_id) ->
    console.log "global:leave room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
    if @isntMyself user_id
      App.Vent.trigger 'push:global:leave', room_id, user_id


  room_join: (room_id, user_id) ->
    console.log "room:join room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
    if @isOtherPlayer room_id, user_id
      App.Vent.trigger 'push:room:join', room_id, user_id

  room_leave: (room_id, user_id) ->
    console.log "room:leave room_id: #{room_id} user_id: #{user_id}, current_user: #{App.currentUser.id}"
    if @isOtherPlayer room_id, user_id
      App.Vent.trigger 'push:room:leave', room_id, user_id

  group_start: (room_id, group_id, group_users) ->
    console.log "group:start room_id: #{room_id} group_id: #{group_id}, current_user: #{App.currentUser.id}, group_users: #{group_users}"
    App.Vent.trigger 'group:start', room_id, group_id, group_users

  group_proposal: (group_id, proposal) ->
    console.log "group:proposal group_id: #{group_id}, proposal: ", proposal
    if @isMyself(proposal.acceptor)
      App.Vent.trigger 'push:group:proposal', group_id, proposal

  group_deal: (group_id, proposal) ->
    console.log "group:deal group_id: #{group_id}, proposal: ", proposal
    if @isMyGroup(group_id)
      App.Vent.trigger 'push:group:deal', group_id, proposal

_.extend App.Listener.prototype, Backbone.Events
