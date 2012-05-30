(function() {
  var app;
  app = window.App;
  if (false) {
    jQuery.noConflict();
    jQuery('.card-none, .card-treasure').live('click', function() {
      var me;
      me = jQuery(this);
      return alert(me.text());
    });
  }
}).call(this);
