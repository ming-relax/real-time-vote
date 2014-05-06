//= require jquery
//= require jquery.ui.effect-highlight
//= require ./lib/underscore

$(function() {
  console.log("admin.js");
  String.format = function() {
    var s = arguments[0];
    for (var i = 0; i < arguments.length - 1; i++) {       
      var reg = new RegExp("\\{" + i + "\\}", "gm");             
      s = s.replace(reg, arguments[i + 1]);
    }

    return s;
  };

  var clear_draw_data = function() {
    $('.nav-info').removeClass("active");
    $('#draw-head').children().remove();
    $('#draw-body').children().remove();
  };

  
  var draw_users = function(users) {
    var head = "<tr><th>Name</th><th>Group id</th></tr>";
    clear_draw_data();
    $('#users').addClass('active');
    $('#draw-head').append(head);
    var body = "";
    
    for (var i = 0; i < users.length; i++) {
      body = body + String.format("<tr><td>{0}</td><td>{1}</td></tr>", 
                                  users[i].username, users[i].group_id);
    }
    $('#draw-body').append(body);


  };

  var draw_groups = function(groups) {
    var head = "<tr><th>#</th><th>Group id</th><th>Round id</th><th>Betray Penalty</th></tr>"; 
    clear_draw_data();
    $('#groups').addClass('active');
    
    var body = "";
    $('#draw-head').append(head);

    for (var i = 0; i < groups.length; i++) {

      body = body + String.format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>", 
                                  i + 1, groups[i].id, groups[i].round_id, groups[i].betray_penalty);
    }
    $('#draw-body').append(body);
  };

  var draw_proposals = function(proposals) {
    var head = "<tr><th>Proposal id</th><th>Submited from</th><th>Submited to</th><th>Round id</th><th>Money info</th><th>Penalty info</th><th>Accepted?</th><th>Submit time</th><th>Accept time</th></tr>";
    clear_draw_data();
    $('#proposals').addClass('active');    
    $('#draw-head').append(head);

    var body = "";
    var from_name = '';
    var to_name = '';
    var money_info = '';
    var penalty_info = '';

    for (var i = 0; i < proposals.length; i++) {
      var p = proposals[i];
      var users = proposals[i].users;
      
      for (var j = 0; j < users.length; j++) {
        if (users[j].id === p.submitter) {
          from_name = users[j].username;
          break;
        }
      }

      for (var j = 0; j < users.length; j++) {
        if (users[j].id === p.acceptor) {
          to_name = users[j].username;
          break;
        }
      }

      money_info = String.format("{0}: {1}  {2}: {3}  {4}: {5}", 
                                  users[0].username, p.moneys[0], users[1].username, p.moneys[1], users[2].username, p.moneys[2]);
      penalty_info = String.format("{0}: {1}  {2}: {3}",
                                   from_name, p.submitter_penalty, to_name, p.acceptor_penalty);

      if (proposals[i].accepted === true)
        body = body + String.format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td></tr>",
                                    p.id, from_name, to_name, p.round_id, money_info, penalty_info, "YES", p.created_at, p.updated_at);
      else
        body = body + String.format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td></tr>",
                                    p.id, from_name, to_name, p.round_id, money_info, penalty_info, "NO", p.created_at, "X");
    }

    $('#draw-body').append(body);


  };

  var init_users = function($elem) {
    $elem.click(function() {
      $.ajax({
        url: '/admin/show_users.json',
        type: 'GET',
        success: function(users) {
          // console.log(users);
          draw_users(users);
        }
      });
      return false;
    });
  };

  var init_groups = function($elem) {
    $elem.click(function() {

      $.ajax({
        url: '/admin/show_groups.json',
        type: 'GET',
        success: function(groups) {
          console.log(groups);
          draw_groups(groups);
        }
      });
      return false;
    });

  };

  var init_proposals = function($elem) {
    $elem.click(function() {
      $.ajax({
        url: '/admin/show_proposals.json',
        type: 'GET',
        success: function(proposals) {
          console.log(proposals);
          draw_proposals(proposals);
        }
      });
      return false;
    });

  };

  init_users($('#users'));
  init_groups($('#groups'));
  init_proposals($('#proposals'));
  $('#users').trigger('click');
});