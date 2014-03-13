
$(document).ready(function(){

  // Masonry
  var container = $('#persons-container');
  var msnry = new Masonry( container[0], {
    itemSelector: '.person-item'
  });

  function addNewPerson(data) {
    updateCount(1);

    var element = '<div id="' + data.id + '" class="person-item">\
                    <img src="' + data.url + '">\
                    <p>' + data.first_name + ' ' + data.last_name + '</p>\
                  </div>';

    var newPersonEl = $(element).prependTo(container);
    msnry.prepended(newPersonEl);
  }

  function removePerson(id) {
    updateCount(-1);
    msnry.remove( $('#'+id) );
    msnry.layout();
  }


  function updateCount(c) {
    var len = container.find('.person-item').length;

    container.removeClass();
    container.addClass('contains-'+(len+c));
  }


  // Socket IO
  var socket = io.connect('http://localhost:1337/', {'force new connection': true});

  socket.on('connect', function(){
    console.log('connected');
  });

  socket.on('disconnect', function(){
    console.log('disconected');
  });

  socket.on('add person', function (data){
    console.log('data', data);
    addNewPerson(data);
  });

  socket.on('remove person', function (id){
    console.log('id', id);
    removePerson(id);
  });

  //test
  window.a = function() {
    var d = {
      "id": "1234567",
      "first_name": "Lorem",
      "last_name": "Ipsum",
      "url": "http://www.faithlineprotestants.org/wp-content/uploads/2010/12/facebook-default-no-profile-pic.jpg"
    }

    addNewPerson(d);
  }

  window.b = function() {
    removePerson("1234567");
  }

});