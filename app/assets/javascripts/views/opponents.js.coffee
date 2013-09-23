class App.Views.Opponent extends Backbone.View

  template: HandlebarsTemplates['opponent']
  events:
    'click #submit': 'submit_proposal'
    'click #accept': 'accept_proposal'

  initialize: ->
    @my_proposal = new App.Models.Proposal()
    @listenTo @my_proposal, 'sync', @submit_success
    @listenTo @model, 'change:proposal', @change_proposal

  submit_proposal: (e) ->
    e.preventDefault()
    $moneys = @.$('form').find('input')
    moneys = []
    $moneys.each (i, e) ->
      moneys.push(parseInt(e.value, 10))

    # setup proposal info
    @my_proposal.set('id', null)
    @my_proposal.set('group_id', App.currentUser.get('group_id'))
    @my_proposal.set('round_id', App.currentUser.get('round_id'))
    @my_proposal.set('submitter', App.currentUser.get('id'))
    @my_proposal.set('acceptor', @model.get('opponent_id'))
    @my_proposal.set('moneys', moneys)
    @my_proposal.set('accepted', false)
    @my_proposal.set('submitter_penalty', 0)
    @my_proposal.set('acceptor_penalty', 0)
    @my_proposal.save()

    console.log "submit proposal: #{@my_proposal.toJSON()}"


  submit_success: ->
    console.log 'submit success'

  change_proposal: ->
    p = @model.get 'proposal'
    if p.accepted is false
      @receive_proposal p
    else
      console.log 'p.accepted is true'


  receive_proposal: (p) ->
    $td = @$('#opponent td');    
    $td[1].textContent = p.moneys[0]
    $td[2].textContent = p.moneys[1]
    $td[3].textContent = p.moneys[2]

    $td.effect("highlight", {}, 3000);

  accept_proposal: (e) ->
    e.preventDefault()
    proposal = @model.get 'proposal'
    proposal.accepted = true
    p = new App.Models.Proposal(proposal)
    p.save()
    console.log p.toJSON()
    console.log 'accept proposal'

  render: ->
    users = @model.get('users')
    @$el.html(@template({users: users}))
    @

class App.Views.Opponents extends Backbone.View
  template: HandlebarsTemplates['opponents']

  render: ->
    @$el.html(@template())
    @collection.forEach @renderOpponent, @
    @

  renderOpponent: (model) ->
    v = new App.Views.Opponent({model: model})
    @.$('.thumbnails').append(v.render().el)