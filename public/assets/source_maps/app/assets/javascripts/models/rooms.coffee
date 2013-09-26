class App.Models.Room extends Backbone.Model

  defaults:
    user_id: null
    username: null
    join: false
    users: []
    group: null



  # I am joining
  join: ->
    return null if @isFull()
    user_id = App.currentUser.get('id')
    username = App.currentUser.get('username')
    @set {user_id: user_id, username: username, "join": true}
    @save null, success: (model, response, option) =>      
      App.Vent.trigger 'rooms:joined', @get 'id'

  # I am leaving
  leave: ->

    @set {"user_id": App.currentUser.id, "join": false}
    @save null, success: (model, response, option) =>
      # console.log @.toJSON()
      App.Vent.trigger 'rooms:leaved', @get 'id'


  add_new_user: (user_id, username) ->
    users = @get 'users'
    users.push {id: user_id, username: username}
    return users
    
  # other is joing
  otherJoin: (user_id, username) ->
    users = @add_new_user(user_id, username)
    console.log users
    @set "users": users
    @trigger 'change'

  # other is leaving
  otherLeave: (user_id) ->
    users = @get('users')
    users = _.filter users, (u) -> u != user_id
    @set 'users', users
    @trigger 'change'

  playerJoin: (user_id, username) ->
    users = @add_new_user user_id, username
    @set 'users', users
    @trigger 'change'

  playerLeave: (user_id) ->
    users = @get 'users'
    users = _.filter users, (u) -> u != user_id
    @set 'users', users
    @trigger 'change'

  
  isFull: ->
    users = @get("users")
    return users.length == 3


class App.Collections.Rooms extends Backbone.Collection
  model: App.Models.Room
  url: "/rooms"

  initialize: ->
    @listenTo App.Vent, 'push:global:join', @otherJoin
    @listenTo App.Vent, 'push:global:leave', @otherLeave
    @listenTo App.Vent, 'push:room:join', @playerJoin
    @listenTo App.Vent, 'push:room:leave', @playerLeave

  otherJoin: (room_id, user_id, username) ->
    @get(room_id).otherJoin(user_id, username)

  otherLeave: (room_id, user_id) ->
    @get(room_id).otherLeave(user_id)

  playerJoin: (room_id, user_id, username) ->
    @get(room_id).playerJoin(user_id, username)

  playerLeave: (room_id, user_id) ->
    @get(room_id).playerLeave(user_id)


  isRoomFull: (room_id) ->
    return @get(room_id).isFull()

  # I am joing/leaving room
  leaveRoom: (room_id) ->
    @get(room_id).leave()

  joinRoom: (room_id) ->
    @get(room_id).join()

