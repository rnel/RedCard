// Require the stuff we need
var express = require('express');
var bodyParser = require('body-parser');
var logger = require('morgan');
var app = express();
var http = require('http').createServer(app);
var io = require('socket.io').listen(http);

var persons = [];
var connectedSocket;


// app.use(bodyParser());
app.use(logger('dev'));
app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');

    next();
  });

http.listen(process.env.PORT || 1337);


/***
  Express
 ***/

// app.all('*', function(req, res, next) {
//   res.writeHead(200, { 'Content-Type': 'text/plain' });
//   next();
// });


app.post('/addperson', function(req, res) {
  // console.log("body: ", bodyParser.json);
  console.log("query: ", req.query);

  var query = req.query;
  var newPerson = {
    'id': '',
    'first_name': '',
    'last_name': '',
    'url': ''
  };

  for (var key in newPerson) {
    if (!query.hasOwnProperty(key)) {
      res.statusCode = 400;
      return res.send('Error 400: Post syntax incorrect.');
    };
  };

  // {
  //   "id": "1234567",
  //   "first_name": "Kien Wai",
  //   "last_name": "E",
  //   "url": "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t1/c0.62.200.200/1517506_10151965422058583_1188767168_n.jpg"
  // }

  newPerson.id = query.id;
  newPerson.first_name = query.first_name;
  newPerson.last_name = query.last_name;
  newPerson.url = query.url;

  // check for duplicates
  persons.push(newPerson);
  sendPerson();

  res.send(newPerson);
  res.json(true);
});


// app.get('*', function(req, res) {
//   res.end('404!');
// });


/***
  Socket.io
 ***/

io
  .on('connection', function (socket) {
    connectedSocket = socket;
    connectedSocket.emit('***** Connected to server *****');
});




function sendPerson() {
  console.log(persons);
  console.log(persons[persons.length-1]);

  connectedSocket.emit('add person', persons[persons.length-1]);
}

