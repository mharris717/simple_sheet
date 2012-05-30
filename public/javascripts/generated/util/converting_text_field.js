(function() {
  var app;
  app = window.App;
  jQuery.fn.convertingTextField = function() {
    return this.each(function() {
      var field, label, setLabelText, setup, toggleVis;
      field = $(this);
      label = $("<span>span label</span>");
      toggleVis = function(showField) {
        if (showField) {
          label.hide();
          return field.show();
        } else {
          label.show();
          return field.hide();
        }
      };
      setLabelText = function() {
        var v;
        v = field.val();
        if (!v || v === '') {
          v = "____";
        }
        return label.text(v);
      };
      setup = function() {
        field.removeClass('converting');
        label.insertBefore(field);
        setLabelText();
        toggleVis(false);
        label.click(function() {
          return toggleVis(true);
        });
        field.change(setLabelText);
        field.blur(function() {
          setLabelText();
          return toggleVis(false);
        });
        return setInterval(setLabelText, 500);
      };
      return setup();
    });
  };
  window.ConvertingTextField = Ember.TextField.extend({
    classNames: ['ember-text-field', 'converting']
  });
  window.ConvertingSelect = Ember.Select.extend({
    classNames: ['ember-select', 'converting']
  });
  setInterval(function() {
    var a;
    try {
      $('input.converting').convertingTextField();
      $('textarea.converting').convertingTextField();
      return $('select.converting').convertingTextField();
    } catch (error) {
      return a = 2;
    }
  }, 500);
}).call(this);
