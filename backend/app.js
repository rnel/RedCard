// Require the stuff we need
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var logger = require('morgan');


var http = require('http').createServer(app);
http.listen(process.env.PORT || 1337);


var io = require('socket.io').listen(http);
var persons = [];
var connectedSocket;


/***
  Express
 ***/

app.use(logger('dev'));
app.use(function(req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type');

  next();
});
app.use(bodyParser());


// app.all('*', function(req, res, next) {
//   res.writeHead(200, { 'Content-Type': 'text/plain' });
//   next();
// });


app.post('/addperson', function(req, res) {
  console.log("Adding person: ", req.body);

  var body = req.body;
  var newPerson = {
    'id': '',
    'first_name': '',
    'last_name': '',
    'url': ''
  };

  for (var key in newPerson) {
    if (!body.hasOwnProperty(key)) {
      res.statusCode = 400;
      return res.send('Error 400: Post syntax incorrect.');
    };
  };

  newPerson.id = body.id;
  newPerson.first_name = body.first_name;
  newPerson.last_name = body.last_name;
  newPerson.url = body.url;

  // TODO: Change to add to DB
  persons.push(newPerson);

  connectedSocket.emit('add person', persons[persons.length-1]);

  res.json(200, {message: 'Success'});
});


app.get('/getpersons', function(req, res) {
  console.log("Retrieving all persons...");

  // TODO: Retrieve from DB

  // res.send('Add success');
  res.json(200, {});
});


app.delete('/removeperson/:id', function(req, res) {
  console.log("Removing person with id: ", req.params.id);

  // TODO: Remove from DB

  connectedSocket.emit('remove person', req.params.id);
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



