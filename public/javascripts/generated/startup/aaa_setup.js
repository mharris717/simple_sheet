(function() {
  var app;
  app = window.App;
  Ember.ENV.CP_DEFAULT_CACHEABLE = true;
  Ember.ENV.VIEW_PRESERVES_CONTEXT = true;
  window.testMode = false;
  window.App = Ember.Application.create();
  app = window.App;
}).call(this);
