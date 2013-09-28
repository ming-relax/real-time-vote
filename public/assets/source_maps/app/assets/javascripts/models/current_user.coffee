class App.Models.CurrentUser extends Backbone.Model
  defaults: {
    username: ''
    loggedIn: false
    room_id: -1
    round_id: -1

    # my total earning
    total_earning: null

    # group sync flag
    is_group_sync: true
    is_myself_sync: true
    
    group: null
  }

  urlRoot: '/users'  
  
  initialize: (data) ->
    @set('group', new App.Models.Group(data.group))
    console.log 'sys inint: ', data.group

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
  

  group: ->
    g = @get('group')

  group_users: ->
    @get('grouop').get('users')

  group_id: ->
    return@get('group').get('id')

  is_group_valid: ->
    loggedIn = @get('loggedIn')

    return false if loggedIn is false

    g_id = @group_id()
    if g_id >= 0
      return true
    else
      return false


  is_loggedIn: ->
    return @get('loggedIn')

  opponents: ->
    me = @get('id')
    users = @get('group').get('users')
    return _.filter users, (u) -> u.id != me

  set_group: (group) ->
    @get('group').set(group)


  set_deal: (p, group_moneys) ->
    @get('group').group_deal(p, group_moneys)

  state: ->
    g = @get('group')
    return "invalid" if g is null
    return g.get('state')
    
