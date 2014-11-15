var express = require('express');
var app = express();
app.use('/static', express.static(__dirname + '/public'));

var http = require('http').Server(app);
var io = require('socket.io')(http);

var dgram = require("dgram");
var server = dgram.createSocket("udp4");

var sensormsg =  new Array();

var clients = new Array();

server.on("error", function (err) {
  console.log("server error:\n" + err.stack);
  server.close();
});


server.on("message", function (msg, rinfo) {
  console.log("server got: " + msg + " from " +
    rinfo.address + ":" + rinfo.port);
    sensormsg.push(msg);
    console.log(msg+"");
    console.log(sensormsg.length);
    
//      while(clients.length > 1 ){
//      latestsensormsg = sensormsg.shift();
//          for(var client in clients){
//              //  client.emit('chat message', latestsensormsg+"");
//              client.broadcast.emit(latestsensormsg+"");
//          }
//    }
    
    
//    var socket = io.connect('127.0.0.1:3000');
//    socket.on('connect', function(){
//        console.log('connect');
//        socket.emit('chat message', msg);
//    });

});


server.on("listening", function () {
  var address = server.address();
  console.log("server listening " +
      address.address + ":" + address.port);
});

server.bind(8080);




app.get('/', function(req, res){
   res.sendfile(__dirname + '/index.html');
});


io.on('connection', function(socket){
   // clients.push(socket);
  io.emit('chat message', "start");
  socket.on('chat message', function(msg){
      if(sensormsg.length >0){
          latestsensormsg = sensormsg.shift();
          io.emit('chat message', latestsensormsg+"");
          console.log(latestsensormsg);
      }else{
        io.emit('chat message', "wait");
      }

  });
});




http.listen(3000, function(){
  console.log('listening on *:3000');
    

    
});
