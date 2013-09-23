class App.Models.CurrentUser extends Backbone.Model
  defaults: {
    username: ''
    loggedIn: false
    room_id: -1
    group_id: -1
    round_id: -1
  }
    
  initialize: ->
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