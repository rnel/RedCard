'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

/**
 * Config
 */
var config = {
  env: 'development',
  mongo: {
    uri: 'mongodb://localhost/Redcard',
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
  "status": Boolean
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
  add: function(user, cb){
    var newUser = new RCUser(user);
    newUser.status = 1;
    newUser.save(function(err) {
      // console.log(err);
      if (err) return false;
      cb(err, true);
    });
  },

  del: function(userid, cb){
    // console.log('deleteUser id', userid);
    RCUser.findOne({id: userid}, function(err, user){
      // console.log("user:", user);
      if(user){
        // console.log("remove id:", user.id);
        RCUser.remove({id: user.id}, function(err){
          if (err) return false;
          cb(err, true);
        });
      }else{
        cb('id not found', false);
      }
    });
  },

  getAll: function(cb){
    RCUser.find(function(err, users){
      if(users){
        // console.log('getUsers:', users);
        cb(users);
        return users;
      }
      return false;
    });
  },

  update: function(userId, data){
    RCUser.find({id: userId}, function(err, user) {
      
    });
  }
};


module.exports = db;