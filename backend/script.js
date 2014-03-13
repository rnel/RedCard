
/* Document Ready */
$(function() {
  var socket = io.connect('http://localhost:1337/', {'force new connection': true});

  socket.on('add person', function (per) {
    console.log(per)
  });


  $('.addPerson').on('click', function() {
    $.ajax({
          url: 'http://localhost:1337/addperson',
          dataType: 'text',
          data: {"id": "1", "url": "http://ignoranthistorian.com/wp-content/uploads/2013/11/apple-logo.jpg", "first_name": "ali", "last_name": "baba"},
          type: 'POST'
        })
        .success(function(data) {
          $('#logger').append('Added: ' + data.first_name + ' ' + data.last_name + '<br />');
        });
  });

});
