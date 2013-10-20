class App.Views.Opponent extends Backbone.View

  template: HandlebarsTemplates['opponent']
  events:
    'click #submit': 'submit_proposal'
    'click #accept': 'accept_proposal'

  initialize: ->

    @my_proposal = new App.Models.Proposal()
    @opponent_proposal = new App.Models.Proposal()

    @listenTo @my_proposal, 'sync', @submit_success
    @listenTo @my_proposal, 'error', @submit_error
    @listenTo @my_proposal, 'invalid', @submit_invalid

    @listenTo @opponent_proposal, 'sync', @deal_success
    @listenTo @opponent_proposal, 'error', @deal_error
    @listenTo @opponent_proposal, 'invalid', @opponent_invalid
        

  submit_proposal: (e) ->
    e.preventDefault()

    if App.currentUser.state() isnt "start"
      return 

    $moneys = @.$('form').find('input')
    moneys = []
    $moneys.each (i, e) ->
      moneys.push(parseInt(e.value, 10))

    # setup proposal info
    
    @my_proposal.set('id', null)
    @my_proposal.set('group_id', App.currentUser.group_id())
    @my_proposal.set('round_id', App.currentUser.get('round_id'))
    @my_proposal.set('submitter', App.currentUser.get('id'))
    @my_proposal.set('acceptor', @model.get('id'))
    @my_proposal.set('moneys', moneys)
    @my_proposal.set('accepted', false)
    @my_proposal.set('submitter_penalty', 0)
    @my_proposal.set('acceptor_penalty', 0)
    @my_proposal.save()

    console.log "submit proposal: #{@my_proposal.toJSON()}"


  submit_success: ->
    console.log 'submit success'
    $td = @.$('#me').find('td')
    moneys = @my_proposal.get('moneys')
    $td[1].textContent = moneys[0]
    $td[2].textContent = moneys[1]
    $td[3].textContent = moneys[2]
    $td.effect("highlight", {}, 3000);

    $input_moneys = @.$('form').find('input')
    $input_moneys.each (i, e) ->
      e.value = ''


  submit_error: ->
    console.log 'submit error'

  submit_invalid: (model, error) ->
    console.log 'submit invalid: ', error
    if I18n.locale is 'cn'
      alert("提案之和必须是100")
    else
      alert("The sum of proposal must be 100")

  deal_success: ->
    deal = @opponent_proposal.get('deal')
    group_moneys = @opponent_proposal.get('group_moneys')

    App.currentUser.set_deal(deal, group_moneys)

    console.log @opponent_proposal.toJSON()

    @opponent_proposal.set('deal', null)
    @opponent_proposal.set('group_moneys', null)

  deal_error: ->
    console.log 'deal error'

  opponent_invalid: (model, error) ->
    console.log 'opponent_proposal invalid: ', error


  receive_proposal: (p) ->
    @opponent_proposal.set(p)
    # console.log 'receive_proposal: ', @model.get('id')
    # console.log 'receive_proposal: ', @opponent_proposal.toJSON()

    $td = @$('#opponent td');
    $td[1].textContent = p.moneys[0]
    $td[2].textContent = p.moneys[1]
    $td[3].textContent = p.moneys[2]

    $td.effect("highlight", {}, 3000)

    console.log 'receive_proposal done'

    # console.log @el

  accept_proposal: (e) ->
    e.preventDefault()

    if App.currentUser.state() isnt "start"
      return

    @opponent_proposal.set({accepted: true})

    @opponent_proposal.save()
    console.log @opponent_proposal.toJSON()
    console.log 'accept proposal'

  render: ->
    state = App.currentUser.state()
    disabled = ""
    if state isnt "start"
      disabled = "disabled"
    else
      disabled = ""
    users = @model.get('users')
    @$el.html(@template({users: users, disabled: disabled}))
    @

class App.Views.Opponents extends Backbone.View
  template: HandlebarsTemplates['opponents']

  initialize: ->
    @opponents = []
    @listenTo App.Vent, 'push:group:proposal', @receive_proposal
  
  render: ->
    # clear it before create new Views
    @opponents = []
    @$el.html(@template())
    @collection.forEach @addOpponent, @
    @

  addOpponent: (model) ->
    v = new App.Views.Opponent({model: model})
    @opponents.push(v)
    @.$('.thumbnails').append(v.render().el)

  receive_proposal: (group_id, proposal) ->
    console.log 'receive_proposal: opponents: ', @opponents.length
    opponent = _.find(@opponents, (v) ->
      v.model.get('id') is proposal.submitter)

    console.assert opponent isnt null

    if opponent
      opponent.receive_proposal(proposal)
