(function() {
  var RelationOption, app;
  app = window.App;
  RelationOption = Em.Object.extend({
    rowFromTable: function(t) {
      var res;
      return res = this.get('rows')[t];
    },
    fields: function() {
      return this.safeGet('relation').safeGet('baseTable').safeGet('workspace').safeGet('fields');
    },
    matches: function(str) {
      var res;
      res = Eval.evalFormula(this, str, this.fields());
      return res;
    }
  });
  app.Relation = Em.Object.extend({
    otherTable: function(baseRow) {
      var bt, ot, res;
      ot = this.safeGet('baseTable').safeGet('workspace').getTable(this.safeGet('otherTableName'));
      res = (function() {
        if (baseRow) {
          bt = baseRow.get('table');
          if (bt !== ot) {
            return ot;
          } else if (bt !== this.get('baseTable')) {
            return this.get('baseTable');
          } else {
            throw "something wrong";
          }
        } else {
          return ot;
        }
      }).call(this);
      if (!res) {
        throw "something wrong no table";
      }
      return res;
    },
    toJson: function() {
      return {
        otherTableName: this.get('otherTableName'),
        formula: this.get('formula'),
        baseTableName: this.get('baseTable').get('name')
      };
    },
    hydrate: function(raw) {
      var k, v, _results;
      _results = [];
      for (k in raw) {
        v = raw[k];
        _results.push(this.set(k, v));
      }
      return _results;
    },
    getRows: function(baseRow) {
      var option, otherRow, res, rows, _i, _len, _ref;
      res = [];
      _ref = this.otherTable(baseRow).get('rows').get('content');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        otherRow = _ref[_i];
        if (true) {
          rows = {};
          rows[baseRow.get('table').get('name')] = baseRow;
          rows[otherRow.get('table').get('name')] = otherRow;
          option = RelationOption.create({
            relation: this,
            rows: rows
          });
          if (option.matches(this.get('formula'))) {
            res.push(otherRow);
          }
        }
      }
      return res;
    }
  });
  app.Relations = Em.ArrayController.extend({
    init: function() {
      return this.set('content', []);
    },
    add: function(otherTable, formula) {
      var ops, r;
      if (isBlank(otherTable)) {
        throw "no table";
      }
      if (isBlank(formula)) {
        throw "no formula";
      }
      ops = {
        baseTable: this.get('table'),
        otherTableName: otherTable,
        formula: formula
      };
      r = app.Relation.create(ops);
      return this.pushObject(r);
    },
    getForTable: function(name, bothDirections) {
      var rel, res, t, _i, _len, _ref;
      if (bothDirections == null) {
        bothDirections = true;
      }
      _ref = this.content;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rel = _ref[_i];
        if (rel.get('otherTableName') === name) {
          return rel;
        }
      }
      if (bothDirections) {
        if (isBlank(this.get('table'))) {
          throw "no table";
        }
        if (isBlank(this.get('table').get('workspace'))) {
          throw "no workspace";
        }
        t = this.get('table').get('workspace').getTable(name, false);
        if (t) {
          res = t.get('relations').getForTable(this.get('table').get('name'), false);
          if (res) {
            return res;
          }
        }
      }
      return;
    },
    relatedTables: function() {
      var res, table, _i, _len, _ref;
      res = [];
      if (this.get('table').get('workspace')) {
        _ref = this.safeGet('table').safeGet('workspace').safeGet('tables').safeGet('content');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          table = _ref[_i];
          if (this.getForTable(table.get('name'))) {
            res.push(table);
          }
        }
      }
      return res;
    }
  });
}).call(this);
