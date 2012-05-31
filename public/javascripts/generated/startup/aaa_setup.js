(function() {
  var app;
  app = window.App;
  Ember.ENV.CP_DEFAULT_CACHEABLE = true;
  Ember.ENV.VIEW_PRESERVES_CONTEXT = true;
  if (window.testMode !== false) {
    window.testMode = true;
  }
  window.App = Ember.Application.create();
  app = window.App;
}).call(this);
