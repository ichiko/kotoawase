(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Tweet;

Vue.prototype.attach = function(selector) {
  return $(selector).append(this.$el);
};

Tweet = (function() {
  function Tweet(name, content) {
    this.name = name;
    this.content = content;
  }

  Tweet.prototype.erase = function() {
    console.log('selected', this.$index);
    return this.$parent.$data.tweets.splice(this.$index, 1);
  };

  return Tweet;

})();

$(function() {
  var content;
  content = new Vue({
    template: '#simple_template',
    data: {
      message: 'vue.js!',
      counter: 0,
      color: 'red',
      tweets: []
    },
    methods: {
      addTweet: function() {
        return this.$data.tweets.push(new Tweet('foo', Date.now()));
      }
    }
  });
  setInterval(function() {
    return content.$data.counter++;
  }, 1000);
  return content.attach('body');
});


},{}]},{},[1])