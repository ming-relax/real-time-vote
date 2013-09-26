class App.Models.CurrentUser extends Backbone.Model
  defaults: {
    username: ''
    loggedIn: false
    room_id: -1
    round_id: -1

    # my total earning
    total_earning: null

    # group sync flag
    is_sync: true
    group: null
  }

  urlRoot: '/users'  
  
  initialize: (data) ->
    @set('group', new App.Models.Group(data.group))
    
    @listenTo App.Vent, "user:logged_in", @logged_in
    @listenTo App.Vent, "user:logged_out", @logged_out

  logged_in: (id, username) ->
    @set id: id, username: username, loggedIn: true 
    App.Vent.trigger "rooms:init"

  logged_out: ->
    m = new App.Models.Login({ id: @id })
    m.destroy
      success: (model, data) =>
          @set loggedIn: false
          @set room_id: -1
          @set group_id: -1
          delete @id
          delete @attributes.username
          delete @attributes.id
          window.csrf(data.csrf)
          App.Vent.trigger "vote:init"
  
  # isMyselfSync: ->
  #   my_round_id = @get('round_id')
  #   group_round_id = @get('group').get('round_id')
  #   if my_round_id is group_round_id
  #     return true
  #   else
  #     return false

  # isGroupSync: ->
  #   return @get('is_sync')

  group: ->
    g = @get('group')

  group_users: ->
    @get('grouop').get('users')

  group_id: ->
    g = @get('group')
    if g
      return g.id
    else
      return -1

  opponents: ->
    me = @get('id')
    users = @get('group').get('users')
    return _.filter users, (u) -> u.id != me

  set_group: (group) ->
    @get('group').set(group)


  set_deal: (p) ->
    @get('group').group_deal(p)
    
