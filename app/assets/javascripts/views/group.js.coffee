class App.Views.Group extends Backbone.View
  template: HandlebarsTemplates['group']
  tagName: 'group'
  events:
    'click #next-round': 'next_round'

  initialize: ->
    current_user_id = App.currentUser.get('id')
    
    console.assert current_user_id >= 0

    users = @model.get('users')
    opponents_collection = new App.Collections.Opponents()

    # 0 is the left two proposals; 1 is in the right
    opponents_collection.at(0).set('users', users)
    opponents_collection.at(1).set('users', users)

    @opponents_view = new App.Views.Opponents({collection: opponents_collection})


    @listenTo App.Vent, 'push:group:deal', @group_deal
    @listenTo App.Vent, 'push:group:sync', @group_sync
    @listenTo @model, 'change', @render
    @listenTo App.currentUser, 'sync', @next_round_rsp
    @listenTo App.currentUser, 'error', @next_round_error

  next_round: (e) ->
    e.preventDefault()

    # round_id += 1
    round_id = App.currentUser.get 'round_id'
    console.assert round_id != -1
    App.currentUser.set 'round_id', round_id + 1
    App.currentUser.save()


  next_round_rsp: ->
    is_sync = App.currentUser.get 'is_sync'
    @model.set({is_sync: is_sync, deal: null})

  next_round_error: ->
    console.log 'next_round_error'

  # update these: 
  # 1) deal.submitter, deal.acceptor; 2) total_earnings, last_earnings
  # show the dialog of next-round button
  group_deal: (group_id, p) ->
    deal = 
      submitter: 'ming',
      acceptor: 'ming2'

    @model.set 'deal', deal

  group_sync: (round_id) ->
    @model.set 'is_sync', true

  render: ->
    @$el.html(@template(@model.toJSON()))
    @.$('#opponents').append(@opponents_view.render().el)
    @