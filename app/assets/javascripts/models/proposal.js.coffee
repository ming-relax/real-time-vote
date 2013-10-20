class App.Models.Proposal extends Backbone.Model
  urlRoot: '/proposals'

  defaults: {
    group_id: null
    round_id: null
    submitter: null
    acceptor: null
    moneys: null
    accepted: null
    submitter_penalty: 0
    acceptor_penalty: 0
  }

  error_string: (attrs, attr_name) ->
    return "error:" + attr_name + ": " + attrs[attr_name]

  validate: (attrs, options) ->
    if (attrs.group_id is null or attrs.group_id <= 0)
      return @error_string(attrs, "group_id")

    if (attrs.round_id is null or attrs.round_id < 0)
      return @error_string(attrs, "round_id") 


    if (attrs.submitter is null)
      return @error_string(attrs, "submitter")

    if (attrs.acceptor is null)
      return @error_string(attrs, "acceptor")

    if (attrs.moneys is null)
      return @error_string(attrs, "moneys")

    sum = attrs.moneys.reduce (t, s) -> t + s
    if (sum isnt 100)
      return @error_string(attrs, "moneys")

    if (attrs.accepted is null)
      return @error_string(attrs, "accepted")