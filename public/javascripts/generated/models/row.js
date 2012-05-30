(function() {
  var app;
  app = window.App;
  app.CompositeRow = Ember.Object.extend({
    init: function() {},
    table: (function() {
      return this.get('rows')[0].get('table');
    }).property('rows.@each'),
    setSums: function() {
      var field, row, sum, _i, _j, _len, _len2, _ref, _ref2, _results;
      _ref = this.get('rows')[0].get('table').get('fields');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        sum = 0;
        _ref2 = this.get('rows');
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          row = _ref2[_j];
          sum += row.getCellValue(field);
        }
        _results.push(this.set(field, sum));
      }
      return _results;
    },
    cellsForField: function(f) {
      return _.map(this.get('rows'), function(row) {
        return row.cellForField(f);
      });
    },
    getCellValue: function(f) {
      var row, sum, v, _i, _len, _ref;
      sum = 0;
      _ref = this.get('rows');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        v = row.getCellValue(f);
        if (isPresent(v) && v !== NaN) {
          sum += v;
        }
      }
      return sum;
    }
  });
  app.Row = Ember.Object.extend({
    init: function() {
      return logger.debug('made a row');
    },
    fieldsBinding: "table.fields",
    cellsInner: (function() {
      var k, res, _i, _len, _ref, _results;
      _ref = this.get('table').get('fields');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        res = app.Cell.create({
          field: k,
          row: this
        });
        _results.push(res);
      }
      return _results;
    }).property('fields').cacheable(),
    cellHash: (function() {
      var cell, res, _i, _len, _ref;
      res = {};
      _ref = this.get('cellsInner');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        res[cell.get('field')] = cell;
      }
      return res;
    }).property('cellsInner').cacheable(),
    cells: (function() {
      var cell, _i, _len, _ref;
      _ref = this.get('cellsInner');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        cell.ensureSetupObservers();
      }
      return this.get('cellsInner');
    }).property('cellsInner').cacheable(),
    cellForField: function(f) {
      return this.get('cellHash')[f];
    },
    getCellValue: function(f) {
      var cell, res;
      cell = this.cellForField(f);
      if (!cell) {
        throw ("no cell " + f + " in table " + (this.get('table').get('name')) + " ") + (this.get('fields') ? this.get('fields').join(",") : "");
      }
      logger.debug("got " + (cell.get('value')) + " for " + f);
      res = cell.get('value');
      if (res && res.match && res.match(/^[0-9]+$/)) {
        res = parseFloat(res);
      }
      return res;
    },
    multiEval: function(str) {
      try {
        return eval(str);
      } catch (error) {
        return eval(CoffeeScript.compile("return " + str));
      }
    },
    evalInContext: function(rawStr) {
      var res;
      res = null;
      try {
        res = Eval.evalFormula(this, rawStr, this.get('table').formulaParser());
      } catch (error) {
        if (testMode) {
          throw error;
        } else {
          res = 'error ' + error;
        }
      }
      return res;
    },
    toJson: function() {
      var cell, res, _i, _len, _ref;
      res = {};
      _ref = this.get('cells');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        res[cell.get('field')] = cell.get('rawValue');
      }
      return res;
    },
    rowFromTable: function(name) {
      var relation, rows;
      if (name === this.get('table').get('name')) {
        return this;
      } else {
        relation = this.get('table').get('relations').getForTable(name);
        if (relation) {
          rows = relation.getRows(this);
          if (!rows) {
            throw "getRows returned garbage";
          } else if (rows.length > 1) {
            return app.CompositeRow.create({
              rows: rows
            });
          } else if (rows.length === 1) {
            return rows[0];
          } else {
            return;
          }
        } else {
          return;
        }
      }
    }
  });
}).call(this);
