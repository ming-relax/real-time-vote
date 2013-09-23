var __ = require('underscore');
var redis = require('redis').createClient();
var connections = [];

var push_global_join = function(msg) {
  console.log('global:join: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'global:join';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });
};

var push_global_leave = function(msg) {
  console.log('global:leave: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'global:leave';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });

};

var push_room_join = function(msg) {
  console.log('room:join: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'room:join';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });
};

var push_room_leave = function(msg) {
  console.log('room:leave: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'room:leave';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });
};

var push_group_start = function(msg) {
  console.log('group:start: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'group:start';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });
};

var push_group_proposal = function(msg) {
  console.log('group:proposal: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'group:proposal';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });

};


var push_group_deal = function(msg) {
  console.log('group:deal: connections: ', connections.length);
  
  var json_msg = JSON.parse(msg);
  json_msg.channel = 'group:deal';
  var str_msg = JSON.stringify(json_msg);

  console.log(json_msg);

  __.each(connections, function(c) {
    c.write(str_msg);
  });

};

redis.on('connect', function() {
  console.log('redis connected!');
});


redis.on("subscribe", function(channel, count) {
  console.log("subscribed: ", channel);
});

redis.on("message", function(channel, msg) {

  if (channel === "global:join")
    push_global_join(msg);
  else if (channel == "global:leave")
    push_global_leave(msg);
  else if (channel == "room:join")
    push_room_join(msg);
  else if (channel == "room:leave")
    push_room_leave(msg);
  else if (channel == "group:start")
    push_group_start(msg);
  else if (channel == "group:proposal")
    push_group_proposal(msg);
  else if (channel == "group:deal")
    push_group_deal(msg);
  else
    console.error('unknown channel: ', channel);

});

redis.subscribe("global:join");
redis.subscribe("global:leave");
redis.subscribe("room:join");
redis.subscribe("room:leave");
redis.subscribe("group:start");
redis.subscribe("group:proposal");
redis.subscribe("group:deal");

// sockJS related stuff
var http = require('http');
var sockjs = require('sockjs');

var io = sockjs.createServer();


io.on('connection', function(conn) {
  connections.push(conn);
  console.log("CONNECTION: ", connections.length);
  conn.on('close', function() {
    
    connections = __.filter(connections, function(c) { return c != conn;});
    // connections.splice(connections.indexOf(conn), 1);
    console.log("CLOSE: ", connections.length);
  });

});

var server = http.createServer();
io.installHandlers(server);
server.listen(5001, '0.0.0.0');


