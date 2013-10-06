class App.Views.Signup extends Backbone.View
  template: HandlebarsTemplates['signup']

  events:
    "click button": "signup"

  initialize: ->
    @listenTo @model, "error", @signup_error
    @listenTo @model, "sync", @signup_ok
  render: ->
    @$el.html(@template())
    @


  signup_error: ->
    @$('.alert').html("choose another username").show()

  signup_ok: (model, rsp, options)->
    # App.currentUser.set
    #   id: rsp.id
    #   username: rsp.username

    App.Vent.trigger "user:logged_in", rsp.id, rsp.username 

  signup: (e) ->
    e.preventDefault()
    @model.set username: @$('#username').val()
    @model.set password: @$('#password').val()
    @model.set weibo: @$('#weibo').val()

    @model.save()
    
