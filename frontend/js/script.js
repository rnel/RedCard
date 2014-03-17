
$(document).ready(function(){

  // Masonry
  var container = $('#persons-container');
  var msnry = new Masonry( container[0], {
    itemSelector: '.person-item'
  });

  var source = $("#card-template").html();
  var template = Handlebars.compile(source);

  function addAllPersons(data) {
    console.log('addAllPersons: ', data);
    container.empty();

    $.each(data, function(index, value){
      addNewPerson(value);
    });
  }

  function addNewPerson(data) {
    var element,
      newPersonEl;

    var existingElement = container.find('#fb'+data.id);
    if (existingElement.length !== 0) {
      existingElement.find('.person-name').text(data.first_name + ' ' + data.last_name)
                     .find('.location').text(data.location)
                     .find('.location').text(data.location)
                     .find('.age').text(data.age)
                     .find('.bio').text(data.bio);

      var profilePhotoEl = existingElement.find('img');
      if (profilePhotoEl.attr('src') != data.url) {
        profilePhotoEl.attr('src', data.url);
      }
    }
    else {
      data.age = (data.birthday) ? getAge(data.birthday) : 'SECRET';
      element = template(data);
      newPersonEl = $(element).appendTo(container);

      updateItemsWidth();
      msnry.appended(newPersonEl);

      // requires relayout
      msnry.layout();
    }

    var len = container.find('.person-item').length;
    if (len > 10) {
      $("html, body").animate({ scrollTop: $(document).height() }, "slow");
    }
  }

  function removePerson(id) {
    msnry.remove( $('#fb'+id) );
    updateItemsWidth(true);
    msnry.layout();
  }

  function focusPerson(id) {
    container
      .find('#fb'+id)
      .effect('shake', {}, 500);
  }

  function updateCount(count) {
    container.removeClass();

    if (count !== 0) {
      container.addClass('contains-' + count);
    }
  }

  function updateItemsWidth(removed) {
    var containerWidth,
      itemsEl = container.find('.person-item'),
      len = itemsEl.length,
      itemWidth,
      maxCols = 5;

    if (removed) {
      --len;
    }

    updateCount(len);
    containerWidth = container.width();

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
  }

  function getAge(dateString) {
    var today = new Date();
    var birthDate = new Date(dateString);
    var age = today.getFullYear() - birthDate.getFullYear();
    var m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  }


  // Socket IO
  // var socket = io.connect('http://localhost:1337/', {'force new connection': true});
  var socket = io.connect('http://192.168.1.76:1337/', {'force new connection': true});

  socket.on('connect', function(msg){
    console.log('connected');
  });

  socket.on('disconnect', function(){
    console.log('disconected');
    socket = io.connect('http://192.168.1.76:1337/', {'force new connection': true});
  });

  socket.on('add all person', function (data){
    console.log('add all', data);
    addAllPersons(data);
  });

  socket.on('add person', function (data){
    console.log('add', data);
    addNewPerson(data);
  });

  socket.on('remove person', function (id){
    console.log('remove', id);
    removePerson(id);
  });

  socket.on('focus person', function (id){
    console.log('focus', id);
    focusPerson(id);
  });

  // test
  window.a = function(id) {
    var d = {
      "id": id || "1234567",
      "first_name": "Lorem",
      "last_name": "Ipsum " + id,
      "gender": "female",
      "location": "Singapore",
      "birthday": "12/20/1981",
      "bio": "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "url": "http://www.faithlineprotestants.org/wp-content/uploads/2010/12/facebook-default-no-profile-pic.jpg"
    }

    addNewPerson(d);
  }

  window.b = function(id) {
    removePerson(id || "1234567");
  }

});

