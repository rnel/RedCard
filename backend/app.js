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


/**
 * init db
 */
var db = require('./lib/db');

// For beacon device
app.post('/addperson', function(req, res) {
  console.log("Adding person: ", req.body);

  var body = req.body;
  var newPerson = {};

  // We may not need to check the post body
  // for (var key in newPerson) {
  //   if (!body.hasOwnProperty(key)) {
  //     res.statusCode = 400;
  //     return res.send('Error 400: Post syntax incorrect.');
  //   };
  // };

  newPerson.id = (body.id) ? body.id : '';
  newPerson.first_name = (body.first_name) ? body.first_name : '' ;
  newPerson.last_name = (body.last_name) ? body.last_name : '';
  newPerson.url = (body.url) ? body.url: '';
  newPerson.gender = (body.gender) ? body.gender : '';
  newPerson.location = (body.location) ? body.location.name : '';
  newPerson.bio = (body.bio) ? body.bio : '';
  newPerson.birthday = (body.birthday) ? body.birthday : '';
  // newPerson.birthday = (body.birthday) ? body.birthday : '';

  // TODO: Change to add to DB
  db.add(newPerson, function(err, result){
    if(err){
      connectedSocket.emit('add person', -1);
    }else{
      connectedSocket.emit('add person', newPerson);
    }
    res.json(200, {message: 'Success'});
  });

  // persons.push(newPerson);
  // console.log(persons[persons.length-1])
  // connectedSocket.emit('add person', persons[persons.length-1]);

  // res.json(200, {message: 'Success'});
});

// For Frontend
app.get('/getpersons', function(req, res) {
  console.log("Retrieving all persons...");

  // TODO: Retrieve from DB
  db.getAll(function(err, results){
    res.json({err: err, result: results});
  });
  // res.send('Add success');
  // res.json(200, {});
});

// For beacon device
app.delete('/removeperson/:id', function(req, res) {
  console.log("Removing person with id: ", req.params.id);

  // TODO: Remove from DB
  db.del(req.params.id, function(err, result){
    if(err){
      connectedSocket.emit('remove person', -1);
      res.json(500, {error: err});
    }else{
      connectedSocket.emit('remove person', req.params.id);
      res.json(200, {message: 'Success'});
    }
  });
});



/***
  Socket.io
 ***/

io
  .on('connection', function (socket) {
    connectedSocket = socket;
    connectedSocket.emit('***** Connected to server *****');
});



