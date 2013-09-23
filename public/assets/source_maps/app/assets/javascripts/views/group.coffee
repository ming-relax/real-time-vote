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

  next_round: (e) ->
    e.preventDefault()
    console.log 'ready to next round'

  # update statistical information about each user's money
  # show the dialog of next-round button
  group_deal: (group_id, p) ->
    console.log 'made a deal: ', p

  render: ->
    users = @model.get('users')
    # @$el.html(@template({'users': users}))
    @$el.html(@template(@model.toJSON()))
    @.$('#opponents').append(@opponents_view.render().el)
    @
