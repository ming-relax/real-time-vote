class App.Views.Room extends Backbone.View
  # tagName: "li"
  # className: "span3"
  template: HandlebarsTemplates['room']


  events:
    "click": "triggerRoomsChange"

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
    if App.currentUser.is_loggedIn()
      App.Vent.trigger "rooms:change", @model.get('id')



  joinOrLeaveFail: (model, xhr, options) ->
    console.log xhr
    if @isJoin()
      alert "join Error"
    else
      alert "Leave Fail" 


  joinOrLeaveSuccess: ->
    if @isJoin()
      @render true
      group = @model.get('group')
      if group
        console.log 'join: ', group
        App.currentUser.set({group_id: group.id, round_id: group.round_id})
        App.currentUser.set_group(group)
        App.Vent.trigger 'group:start'

    else
      @render false


  isJoin: ->
    return @model.get('join')

class App.Views.Rooms extends Backbone.View

  # tagName: 'ul'
  # className: "thumbnails"

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
