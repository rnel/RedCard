
/* Document Ready */
$(function() {
  var socket = io.connect('http://192.168.1.76:1337/', {'force new connection': true});

  socket.on('add person', function (per) {
    console.log(per)
  });


  $('.addPerson').on('click', function() {
    $.ajax({
          url: 'http://192.168.1.76:1337/addperson?id=1&first_name=ali&last_name=baba&url=http://ignoranthistorian.com/wp-content/uploads/2013/11/apple-logo.jpg',
          // url: 'http://192.168.1.76:1337/addperson',
          // data: {"id": "1", "url": "test"},
          // contentType: 'application/json',
          dataType: 'text',
          type: 'POST'
        })
        .success(function(data) {
          $('#logger').append(data + '<br />');
        });
  });

});
