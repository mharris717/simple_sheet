(function() {
  var app;
  var __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  app = window.App;
  app.Formulas = Ember.Object.extend({
    init: function() {
      return this.set('fieldHash', {});
    },
    setFormula: function(k, v) {
      this.set(k, v);
      return this.get('fieldHash')[k] = v;
    },
    fields: function() {
      return _.keys(this.get('fieldHash'));
    }
  });
  app.Table = Em.Object.extend({
    init: function() {
      this.set('rows', Ember.ArrayController.create({
        content: []
      }));
      this.set('formulas', app.Formulas.create());
      this.set('addlFields', Ember.ArrayController.create({
        content: []
      }));
      return this.set('relations', App.Relations.create({
        table: this
      }));
    },
    save: function() {
      return 4;
    },
    saveName: function() {
      return this.get('name');
    },
    setFormula: function(k, v) {
      return this.get('formulas').setFormula(k, v);
    },
    fieldsFromRows: (function() {
      var k, res, row, v, _i, _len, _ref;
      res = {};
      _ref = this.get('rows').get('content');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        for (k in row) {
          if (!__hasProp.call(row, k)) continue;
          v = row[k];
          if (k !== '_super' && k !== 'table' && !k.match(/binding$/i)) {
            res[k] = true;
          }
        }
      }
      return _.keys(res);
    }).property('rows.@each').cacheable(),
    fields: (function() {
      var res;
      res = this.get('fieldsFromRows');
      res = res.concat(this.get('addlFields').get('content'));
      return _.uniq(res);
    }).property('fieldsFromRows', 'addlFields.@each'),
    fieldsForParser: function() {
      var res, table, _i, _len, _ref;
      res = this.get('fields');
      _ref = this.get('relations').relatedTables();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        table = _ref[_i];
        res = res.concat(table.get('fieldsFromRows'));
      }
      return _.uniq(res);
    },
    columns: (function() {
      var f, _i, _len, _ref, _results;
      _ref = this.get('fields');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        _results.push(app.Column.create({
          table: this,
          field: f
        }));
      }
      return _results;
    }).property('fields'),
    addRow: function(h) {
      var k, row, _i, _len, _ref;
      _ref = this.get('formulas').fields();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        h[k] || (h[k] = null);
      }
      row = app.Row.create(h);
      row.set('table', this);
      this.get('rows').pushObject(row);
      return row;
    },
    setupAll: function() {
      var cell, row, _i, _len, _ref, _results;
      logger.log("setupAll");
      _ref = this.get('rows').get('content');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        _results.push((function() {
          var _i, _len, _ref, _results;
          _ref = row.get('cells');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            cell = _ref[_i];
            cell.setupObservers();
            _results.push(cell.recalc());
          }
          return _results;
        })());
      }
      return _results;
    },
    addColumn: function(col, form) {
      this.get('addlFields').pushObject(col);
      if (isPresent(form)) {
        return this.setFormula(col, form);
      }
    },
    addRelation: function(otherTable, formula) {
      return this.get('relations').add(otherTable, formula);
    },
    formulaParser: function() {
      return this.cachedParser || (this.cachedParser = Eval.getFormulaParser({
        vars: this.fieldsForParser()
      }));
    },
    countCell: (function() {
      return this.get('rows').get('content').length;
    }).property('rows.@each'),
    toJson: function() {
      var res;
      res = {};
      res.formulas = this.get('formulas').get('fieldHash');
      res.addlFields = this.get('addlFields').toJson();
      res.rows = this.get('rows').toJson();
      res.relations = this.get('relations').toJson();
      res.name = this.get('name');
      return res;
    },
    hydrate: function(raw) {
      var f, k, row, v, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _ref4, _results;
      this.set('name', raw.name);
      _ref = raw.formulas;
      for (k in _ref) {
        v = _ref[k];
        this.setFormula(k, v);
      }
      _ref2 = raw.addlFields;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        f = _ref2[_i];
        this.addColumn(f);
      }
      _ref3 = raw.rows;
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        row = _ref3[_j];
        this.addRow(row);
      }
      _ref4 = raw.relations;
      _results = [];
      for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
        row = _ref4[_k];
        _results.push(this.addRelation(row.otherTableName, row.formula));
      }
      return _results;
    },
    loadCSV: function(csv) {
      return $.post("/convert", {
        body: csv
      }, __bind(function(rows) {
        var row, _i, _len;
        console.debug("csv " + rows.length + " for " + (this.get('name')));
        for (_i = 0, _len = rows.length; _i < _len; _i++) {
          row = rows[_i];
          this.addRow(row);
        }
        console.debug('saving csv');
        return SimpleSave.save(this);
      }, this), 'json');
    }
  });
  app.TableView = Em.View.extend({
    templateName: "views_table",
    workspaceBinding: "table.workspace",
    "delete": function(e) {
      return this.get('workspace').removeTable(this.get('table'));
    },
    showSettings: function(e) {
      return this.$('.settings').show();
    },
    showCSV: function(e) {
      return this.$('.load-csv').show();
    },
    loadCSV: function(e) {
      this.get('table').loadCSV(this.get('csvContent'));
      this.$('.load-csv').hide();
      return this.$('.settings').hide();
    }
  });
  app.Table.load = function() {
    var raw, res;
    raw = $.jStorage.get('table');
    res = null;
    if (raw && raw.rows.length && raw.rows.length > 0) {
      res = app.Table.create();
      res.hydrate(raw);
    } else {
      res = makeFreshTable();
    }
    return res;
  };
}).call(this);
