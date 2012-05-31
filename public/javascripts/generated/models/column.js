(function() {
  var app;
  app = window.App;
  app.Column = Ember.Object.extend({
    init: function() {
      return this.set('incValue', 0);
    },
    fullField: (function() {
      return "" + (this.get('table').get('name')) + "." + (this.get('field'));
    }).property('table.name', 'field'),
    recalc: function() {
      return this.incrementProperty('incValue');
    },
    formula: (function(k, v) {
      if (arguments.length === 1) {
        return this.get('table').get('formulas').get(this.get('field'));
      } else {
        this.get('table').setFormula(this.get('field'), v);
        return v;
      }
    }).property('table.formulas'),
    values: (function() {
      return this.get('table').get('rows').map(function(row) {
        return row.getCellValue(this.get('field'));
      });
    }).property('incValue'),
    setupObservers: function() {
      var cell, row, _i, _len, _ref;
      _ref = this.get('table').get('rows').get('content');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        cell = row.cellForField(this.get('field'));
        cell.addObserver('value', this, this.recalc);
      }
      return this.get('table').addObserver('countCell', this, this.recalc);
    }
  });
}).call(this);
