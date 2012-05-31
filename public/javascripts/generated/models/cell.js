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
    value: (function() {
      var rest, row;
      res = this.get('rawValueOrFormula');
      row = this.get('row');
      res = res && res.substr && res.substr(0, 1) === '=' ? (rest = res.substr(1, 999), logger.debug("eval " + (this.get('field')) + " | " + rest), res = row.evalInContext(rest), _.isNumber(res) ? res = roundNumber(res, 3) : void 0, res) : res;
      if (res && res.toValue) {
        res = res.toValue();
      }
      return res;
    }).property('rawValue', 'row.table.workspace.relations.@each.formula').cacheable(),
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
  Array.prototype.max = function() {
    var obj, _i, _len;
    res = this[0];
    if (this.length === 0) {
      return res;
    }
    if (this.length === 1) {
      return this[0];
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      if (obj) {
        obj = parseFloat(obj);
      }
      if (!res) {
        res = obj;
      } else if (obj && obj > res) {
        res = obj;
      }
    }
    return res;
  };
  Array.prototype.min = function() {
    var obj, _i, _len;
    res = this[0];
    if (this.length === 0) {
      return res;
    }
    if (this.length === 1) {
      return this[0];
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      if (obj) {
        obj = parseFloat(obj);
      }
      if (!res) {
        res = obj;
      } else if (obj && obj < res) {
        res = obj;
      }
    }
    return res;
  };
  Array.prototype.sum = function() {
    var obj, _i, _len;
    if (this.length === 0) {
      return 0;
    }
    res = 0;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      console.debug(obj);
      if (obj) {
        res += parseFloat(obj);
      }
    }
    return res;
  };
  app.Cell.CompositeCell = Em.Object.extend({
    toValue: function(type) {
      if (type == null) {
        type = 'sum';
      }
      if (type === 'max') {
        return this.get('values').max();
      } else if (type === 'min') {
        return this.get('values').min();
      } else if (type === 'sum') {
        return this.get('values').sum();
      }
    },
    values: (function() {
      return this.get('cells').map(function(obj) {
        return obj.get('value');
      });
    }).property('cells.@each.value')
  });
}).call(this);
