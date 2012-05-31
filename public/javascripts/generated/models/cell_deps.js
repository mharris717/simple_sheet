(function() {
  var app, getForeignFieldsFromFormula;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  app = window.App;
  app.CellDeps = Em.Object.extend({
    rowBinding: "cell.row",
    tableBinding: "cell.row.table",
    localDeps: function() {
      var v;
      v = this.get('value');
      if (v && v.match) {
        return this.get('cell').get('row').get('table').get('fields').filter(__bind(function(f) {
          return v.match(f);
        }, this));
      } else {
        return [];
      }
    }
  }, getForeignFieldsFromFormula = function(str) {
    var res;
    res = str && str.match ? str.scan(/\$[a-z_]+\.[a-z_]+/) || [] : [];
    return res.map(function(full) {
      var arr;
      arr = full.substr(1, 999).split(".");
      if (arr.length !== 2) {
        throw "not 2";
      }
      return {
        table: arr[0],
        field: arr[1]
      };
    });
  }, {
    foreignDeps: function() {
      return getForeignFieldsFromFormula(this.get('value'));
    },
    cells: function() {
      var cellsForRelation, dep, deps, foreign, foreignRow, res, _i, _len, _ref;
      cellsForRelation = __bind(function(aDep) {
        var dep, relation, res, table, _i, _len, _ref;
        res = [];
        relation = this.get('cell').get('row').get('table').get('relations').getForTable(aDep.table);
        table = this.get('cell').get('row').get('table').get('workspace').getTable(aDep.table);
        if (relation) {
          _ref = getForeignFieldsFromFormula(relation.get('formula'));
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            dep = _ref[_i];
            if (dep.table !== this.get('cell').get('row').get('table').get('name')) {
              res.push([table, "rows.@each." + dep.field]);
            } else {
              res.push(this.get('cell').get('row').cellForField(dep.field));
            }
          }
        }
        return res;
      }, this);
      deps = this.localDeps();
      res = this.get('cell').get('row').get('cellsInner').filter(__bind(function(cell) {
        return _.include(deps, cell.get('field'));
      }, this));
      foreign = [];
      _ref = this.foreignDeps();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dep = _ref[_i];
        foreignRow = this.get('cell').get('row').rowFromTable(dep.table);
        if (foreignRow) {
          if (foreignRow.cellsForField) {
            foreign = foreign.concat(foreignRow.cellsForField(dep.field));
          } else {
            foreign.push(foreignRow.cellForField(dep.field));
          }
          foreign = foreign.concat(cellsForRelation(dep));
        }
      }
      return res.concat(foreign);
    },
    setupObservers: function() {
      var cell, _i, _len, _ref;
      _ref = this.cells();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        if (cell) {
          if (cell.length && cell.length === 2) {
            cell[0].removeObserver(cell[1], this.get('cell'), this.get('cell').recalcSpecial);
            cell[0].addObserver(cell[1], this.get('cell'), this.get('cell').recalcSpecial);
          } else {
            cell.removeObserver('value', this.get('cell'), this.get('cell').recalc);
            cell.addObserver('value', this.get('cell'), this.get('cell').recalc);
          }
        }
      }
      this.get('cell').get('row').get('table').get('formulas').removeObserver(this.get('cell').get('field'), this.get('cell'), this.get('cell').recalc);
      return this.get('cell').get('row').get('table').get('formulas').addObserver(this.get('cell').get('field'), this.get('cell'), this.get('cell').recalc);
    }
  });
}).call(this);
