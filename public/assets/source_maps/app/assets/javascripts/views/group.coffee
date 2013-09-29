class App.Views.Group extends Backbone.View
  template: HandlebarsTemplates['group']
  tagName: 'group'
  events:
    'click #next-round': 'next_round'
    'click #exit': 'exit_group'

  initialize: ->
    current_user_id = App.currentUser.get('id')
    
    console.assert current_user_id >= 0

    users = @model.get('users')
    opponents_collection = new App.Collections.Opponents()

    # 0 is the left two proposals; 1 is in the right
    opponents_collection.at(0).set('users', users)
    opponents_collection.at(1).set('users', users)

    @opponents_view = new App.Views.Opponents({collection: opponents_collection})

    @listenTo @model, 'change', @render
    @listenTo @model, 'sync', @exit_group_success
    @listenTo @model, 'error', @exit_group_error

    @listenTo App.Vent, 'push:group:deal', @group_deal
    @listenTo App.Vent, 'push:group:sync', @group_sync

    @listenTo App.currentUser, 'sync', @next_round_rsp
    @listenTo App.currentUser, 'error', @next_round_error
    
    @model.init_group_state()

  exit_group: (e) ->
    e.preventDefault()
    @model.set 'user_id', App.currentUser.get('id')
    @model.save()
    console.log 'exit_group'

  exit_group_success: ->
    App.currentUser.exit_group(myself:true)

  exit_group_error: ->
    console.log 'exit_group_error'

  next_round: (e) ->
    e.preventDefault()

    round_id = App.currentUser.get 'round_id'
    console.assert round_id != -1
    App.currentUser.set 'round_id', round_id + 1
    App.currentUser.save()


  next_round_rsp: ->
    is_group_sync = App.currentUser.get('is_group_sync')
    if is_group_sync
      @model.group_sync(App.currentUser.get('round_id'))
    else
      @model.group_wait()
      
    @model.trigger 'change'

  next_round_error: ->
    console.log 'next_round_error'

  # update these: 
  # 1) deal.submitter, deal.acceptor; 2) total_earnings, last_earnings
  # show the dialog of next-round button
  group_deal: (group_id, deal, group_moneys) ->
    @model.group_deal(deal, group_moneys)

  group_sync: (round_id) ->
    @model.group_sync(round_id)

  extract_deal_context: (p) ->
    submitter = null
    acceptor = null
    users = @model.get('users')
    for u in users
      submitter = u.username if u.id is p.submitter
      acceptor = u.username if u.id is p.acceptor

    [submitter, acceptor]
    

  render: ->
    console.log 'render_group'
    current_deal = @model.get('current_deal')
    last_deal = @model.get('last_deal')
    new_deal = null
    wait_others = false
    group_state = @model.get('state')
    last_earnings = [-1, -1, -1]
    if group_state is "start"
      new_deal = null
      wait_others = false
      if last_deal
        last_earnings = last_deal.moneys
      else
        last_earnings = [0, 0, 0]
    else if group_state is "deal"
      new_deal = {}
      [new_deal.submitter, new_deal.acceptor] = @extract_deal_context(current_deal)
      wait_others = false
      last_earnings = current_deal.moneys
    else if group_state is "wait_others"
      new_deal = null
      wait_others = true
      last_earnings = last_deal.moneys
    @$el.html(@template(
      {
        round_id: @model.get('round_id'),
        betray_penalty: @model.get('betray_penalty')
        users: @model.get('users'), 
        wait_others: wait_others,
        new_deal: new_deal
        total_earnings: @model.get('moneys'),
        last_earnings: last_earnings
      }
      ))

    @.$('#opponents').append(@opponents_view.render().el)
    @
