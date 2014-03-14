
/* Document Ready */
$(function() {
  var socket = io.connect('http://localhost:1337/', {'force new connection': true});

  socket.on('add person', function (per) {
    console.log("add: ", per);
  });

  socket.on('remove person', function (id) {
    console.log("remove:", id);
  });

  socket.on('get person', function (pers) {
    console.log("persons:", pers);
  });

  // for beacon device
  $('.addPerson').on('click', function() {
    $.ajax({
          url: 'http://localhost:1337/addperson',
          data: {"id": "1", "url": "http://ignoranthistorian.com/wp-content/uploads/2013/11/apple-logo.jpg", "first_name": "ali", "last_name": "baba"},
          type: 'POST'
        })
        .success(function(data) {
          $('#logger').append('Added: ' + data.first_name + ' ' + data.last_name + '<br />');
        });
  });

  // for beacon device
  $('.removePerson').on('click', function() {
    $.ajax({
        url: 'http://localhost:1337/removeperson/1',
        type: 'DELETE'
      })
      .success(function(data) {
        console.log("delete:", data);
      });
  });

  // frontend
  $('.getPerson').on('click', function() {
    $.ajax({
        url: 'http://localhost:1337/getpersons',
        type: 'GET'
      })
      .success(function(data) {
        console.log("get:", data);
      });
  });
});
