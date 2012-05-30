(function() {
  var app;
  app = window.App;
  window.logger = {
    log: function(str) {
      if (!isBlank(str)) {
        return console.debug(str);
      }
    },
    debug: function(str) {}
  };
}).call(this);
