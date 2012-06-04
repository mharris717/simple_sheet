(function() {
  var app, res;
  app = window.App;
  window.roundNumber = function(num, dec) {
    return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
  };
  app.Cell = Ember.Object.extend({
    tableBinding: "row.table",
    init: function() {
      return logger.debug("making a cell " + this.get('field'));
    },
    recalc: function() {
      return this.notifyPropertyChange('rawValue');
    },
    recalcSpecial: function() {
      return this.notifyPropertyChange('rawValue');
    }
  }, res = Ember.computed(function(k, v) {
    var f, row;
    f = this.get('field');
    row = this.get('row');
    if (arguments.length === 1) {
      logger.debug("getting rawValue");
      return row.get(f);
    } else {
      logger.debug("setting rawValue to " + v);
      row.set(f, v);
      return v;
    }
  }), {
    rawValue: res.property().cacheable(),
    rawValueOrFormula: (function() {
      res = this.get('rawValue');
      if (isBlank(res)) {
        res = this.get('columnFormula');
      }
      return res;
    }).property('rawValue', 'columnFormula'),
    columnFormula: (function() {
      return this.get('row').get('table').get('formulas').get(this.get('field'));
    }).property("row.table.formulas"),
    primitiveValue: (function() {
      var row;
      res = this.get('rawValueOrFormula');
      row = this.get('row');
      res = Eval.isFormula(res) ? (res = row.evalInContext(res), _.isNumber(res) ? res = roundNumber(res, 3) : void 0, res) : res;
      return res;
    }).property('rawValue', 'row.table.workspace.relations.@each.formula').cacheable(),
    value: (function() {
      res = this.get('primitiveValue');
      if (res && res.toValue) {
        return res.toValue();
      } else {
        return res;
      }
    }).property('primitiveValue'),
    areObserversSetup: false,
    ensureSetupObservers: function() {
      if (!this.areObserversSetup) {
        this.setupObservers();
        return this.areObserversSetup = true;
      }
    },
    setupObservers: function() {
      var d;
      d = app.CellDeps.create({
        cell: this,
        value: this.get('rawValueOrFormula')
      });
      return d.setupObservers();
    },
    triggerSave: function() {
      return this.get('table').save();
    },
    rawValueChanged: (function() {
      this.setupObservers();
      if (!testMode) {
        return this.triggerSave();
      }
    }).observes('rawValue')
  });
  app.Cell.CompositeCell = Em.Object.extend({
    toValue: function(type) {
      if (type == null) {
        type = 'sum';
      }
      return this.get('values')[type]();
    },
    values: (function() {
      return this.get('cells').map(function(obj) {
        return obj.get('value');
      });
    }).property('cells.@each.value')
  });
}).call(this);
