class App.Views.Room extends Backbone.View
  tagName: "li"
  className: "span3"
  template: HandlebarsTemplates['room']


  events:
    "click": "triggerRoomsChange"
    "mouseover": "hoverRoom"

  initialize: ->
    @listenTo @model, 'error', @joinOrLeaveFail
    @listenTo @model, 'sync', @joinOrLeaveSuccess
    @listenTo @model, 'change', @render

  render: (join=false) ->
    # console.log 'render room: ', @model.toJSON() 
    empty_seats = 3 - @model.get("users").length
    join = @model.get 'join'
    if join
      @$el.html(@template({empty_seats: empty_seats, join: true}))
    else
      @$el.html(@template({empty_seats: empty_seats}))
    @
    
  triggerRoomsChange: (e) ->
    e.preventDefault()
    App.Vent.trigger "rooms:change", @model.get('id')

  hoverRoom: (e) ->
    # console.log 'hover'
    # @$el.css('background-color', "hsla(300, 20%, 50%, 0.8)");


  joinOrLeaveFail: ->

  joinOrLeaveSuccess: ->
    if @isJoin()
      @render true
      group_users = @model.get('users')
      group_users.sort()
      App.currentUser.set 'group_users', group_users
      if group_users.length is 3
        group_id = @model.get('group_id')
        round_id = @model.get('round_id')
        App.currentUser.set 'group_id', group_id
        App.currentUser.set 'round_id', round_id
        App.Vent.trigger 'group:start'
    else
      @render false


  isJoin: ->
    users = @model.get('users')
    user_id = @model.get('user_id')
    return (-1 != _.indexOf(users, user_id))


class App.Views.Rooms extends Backbone.View

  tagName: 'ul'
  className: "thumbnails"

  initialize: ->
    @rooms = []
    @listenTo @collection, 'reset', @triggerRoomsReady
    @listenTo App.Vent, 'rooms:change', @changeRoom
    @listenTo App.Vent, 'rooms:leaved', @leavedRoom
    @listenTo App.Vent, 'rooms:joined', @joinedRoom

    @collection.fetch({reset:true})

  triggerRoomsReady: -> 
    
    room_id = App.currentUser.get 'room_id'
    if room_id isnt -1
      @collection.get(room_id).set('join', true)

    App.Vent.trigger "rooms:ready", @

  changeRoom: (target_room_id) ->
    current_room_id = App.currentUser.get('room_id')
    console.log "*** current_room_id: #{current_room_id}, target_room_id: #{target_room_id} ***"

    return null if @collection.isRoomFull target_room_id
    return null if current_room_id is target_room_id

    if current_room_id isnt -1
      @collection.leaveRoom current_room_id

    @collection.joinRoom target_room_id

  leavedRoom: (room_id) ->
    # console.log "leavedRoom: #{room_id}"
    # App.currentUser.set 'room_id', -1

  joinedRoom: (room_id) ->
    # console.log "joinedRoom: #{room_id}"
    App.currentUser.set 'room_id', room_id

  render: ->
    @collection.forEach @renderRoom, @
    @

  renderRoom: (model) ->
    roomView = new App.Views.Room({model: model})
    @rooms.push roomView
    @$el.append(roomView.render().el)
