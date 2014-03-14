
$(document).ready(function(){

  // Masonry
  var container = $('#persons-container');
  var msnry = new Masonry( container[0], {
    itemSelector: '.person-item'
  });

  var source = $("#card-template").html();
  var template = Handlebars.compile(source);
  var containerWidth = container.width();

  function addNewPerson(data) {
    var element = template(data),
      newPersonEl = $(element).appendTo(container);
    
    updateItemsWidth();
    msnry.appended(newPersonEl);

    // requires relayout
    msnry.layout();

    $("html, body").animate({ scrollTop: $(document).height() }, "slow");
  }

  function removePerson(id) {
    msnry.remove( $('#fb'+id) );
    updateItemsWidth(true);
    msnry.layout();
  }

  function updateCount(count) {
    container.removeClass();

    if (count !== 0) {
      container.addClass('contains-' + count);
    }
  }

  function updateItemsWidth(removed) {
    var itemsEl = container.find('.person-item'),
      len = itemsEl.length,
      itemWidth,
      maxCols = 5;

      if (removed) {
        --len;
      }

    if (len <= 2) {
      itemWidth = containerWidth / len;
    }
    else {
      var cols = Math.ceil(len/2);

      if (cols < maxCols) {
        itemWidth = containerWidth / Math.ceil(len/2);
      }
      else {
        itemWidth = containerWidth / maxCols;
      }

    }

    itemsEl.width(itemWidth);
    updateCount(len);
  }


  // Socket IO
  // var socket = io.connect('http://localhost:1337/', {'force new connection': true});
  var socket = io.connect('http://192.168.1.76:1337/', {'force new connection': true});

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


  // test
  window.a = function(id) {
    var d = {
      "id": id || "1234567",
      "first_name": "Lorem",
      "last_name": "Ipsum " + id,
      "url": "http://www.faithlineprotestants.org/wp-content/uploads/2010/12/facebook-default-no-profile-pic.jpg"
    }

    addNewPerson(d);
  }

  window.b = function(id) {
    removePerson(id || "1234567");
  }

});