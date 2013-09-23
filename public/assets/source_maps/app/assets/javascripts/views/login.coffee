class App.Views.Login extends Backbone.View
  template: HandlebarsTemplates['login']

  events:
    "click button": "login"


  initialize: ->
    @listenTo @model, 'error', @renderError
    @listenTo @model, 'sync', @triggerLogin

  render: ->
    @$el.html(@template())
    @

  renderError: ->
    @$('.alert').html("Credentials are not valid").show()

  login: (e) ->
    e.preventDefault()
    @model.set username: @$('#username').val()
    @model.set password: @$('#password').val()
    # console.log 'login: ', @model.toJSON()
    @model.save()

  triggerLogin: (model, resp, options)->
    # console.log 'logged_in: ', resp
    if resp.room_id and resp.room_id isnt -1
      App.currentUser.set 'room_id', resp.room_id

    App.Vent.trigger "user:logged_in", @model.get('id'), @model.get('username') 
