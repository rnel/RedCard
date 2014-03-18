'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

/**
 * Config
 */
var config = {
  env: 'development',
  mongo: {
    uri: 'mongodb://redcard:kw4redcard@oceanic.mongohq.com:10017/redcard',
    options: {}
  }
};


/**
 * Create Connection
 */
var dbconn = mongoose.connect(config.mongo.uri, config.mongo.options);
// console.log("conn:", dbconn);

/**
 * User Schema
 */
var RCUserSchema = new Schema({
  "id": String,
  "first_name": String,
  "last_name": String,
  "url": String,
  "status": Boolean,
  "gender": String,
  "location": String,
  "bio": String,
  "birthday": String
});


/**
 * Instantiate Model
 */
var RCUser = mongoose.model('RCUser', RCUserSchema, 'Users');


/**
 * db Methods
 */

var db = {

  /**
   * Add New User
   */
  findOne: function(userId){
    console.log('userId:', userId);
    RCUser.find({id: userId}, function(err, user){
      if(err) return false;
      return user;
      console.log('user:', user);
    });
  },

  add: function(user, cb){
    var newUser = new RCUser(user);
    newUser.status = 1;
    // console.log (this.findOne(newUser.id));
    RCUser.findOne({id: newUser.id}, function(err, user){
      if(err) return false;
      // console.log('user:', user.id);
      if( user ){
        // update
        user.gender = newUser.gender || 'M';
        user.location = newUser.location || 'location';
        user.bio = newUser.bio || 'string';
        user.birthday = newUser.birthday || 'jan 1, 1990';

        user.save(function(err){
          cb(err, user);
        });
      }else{
        // new
        newUser.save(function(err) {
          cb(err, newUser);
        });
      }
    });
  },

  del: function(userid, cb){
    RCUser.findOne({id: userid}, function(err, user){
      if(user){
        RCUser.remove({id: user.id}, function(err){
          cb(err, user.id);
        });
      }
    });
  },

  getAll: function(cb){
    RCUser.find(function(err, users){
      cb(err, users);
    });
  },

  update: function(userId, data){
    RCUser.find({id: userId}, function(err, user) {

    });
  }
};


module.exports = db;
