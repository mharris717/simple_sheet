(function() {
  var app;
  app = window.App;
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
            return app.Row.CompositeRow.create({
              rows: rows
            });
          } else if (rows.length === 1) {
            return rows[0];
          } else {
            return app.Row.NullRow.create();
          }
        } else {
          return;
        }
      }
    }
  });
  app.Row.CompositeRow = Ember.Object.extend({
    table: (function() {
      return this.get('rows')[0].get('table');
    }).property('rows.@each'),
    cellsForField: function(f) {
      return _.map(this.get('rows'), function(row) {
        return row.cellForField(f);
      });
    },
    cellForField: function(f) {
      var cells;
      cells = this.get('rows').map(function(row) {
        return row.cellForField(f);
      });
      return app.Cell.CompositeCell.create({
        cells: cells
      });
    },
    getCellValue: function(f, type) {
      var res;
      res = this.cellForField(f);
      if (type && res && res.toValue) {
        res = res.toValue(type);
      }
      return res;
    }
  });
  app.Row.NullRow = Ember.Object.extend({
    getCellValue: function(f) {
      return;
    },
    cellForField: function(f) {
      return;
    }
  });
}).call(this);
