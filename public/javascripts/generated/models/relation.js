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
    "delete": function() {
      return this.get('baseTable').get('relations').removeObject(this);
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
  app.Relation.ManageView = Em.View.extend({
    templateName: "views_relation_manage"
  });
  app.Relation.NewView = Em.View.extend({
    templateName: "views_relation_new",
    fullField1: (function() {
      if (this.get('field1')) {
        return this.get('field1').get('fullField');
      } else {
        return "<span class='small-message'>(Click field to set)</span>";
      }
    }).property('field1'),
    fullField2: (function() {
      if (this.get('field2')) {
        return this.get('field2').get('fullField');
      } else if (this.get('field1')) {
        return "<span class='small-message'>(Click field to set)</span>";
      } else {
        return;
      }
    }).property('field1', 'field2'),
    pickField: function(e) {
      var col;
      col = e.context;
      if (!this.get('field1')) {
        return this.set('field1', col);
      } else {
        return this.set('field2', col);
      }
    },
    create: function(e) {
      var forForm, formula, table;
      table = this.get('field1').get('table');
      forForm = function(f) {
        return "$" + (f.get('table').get('name')) + "." + (f.get('field'));
      };
      formula = "" + (forForm(this.get('field1'))) + " == " + (forForm(this.get('field2')));
      table.addRelation(this.get('field2').get('table').get('name'), formula);
      this.set('field1', void 0);
      return this.set('field2', void 0);
    }
  });
  app.Relation.NewColumnsView = Em.View.extend({
    templateName: "views_relation_new_columns",
    pickField: function(e) {
      return this.get('parentView').pickField(e);
    }
  });
  app.Relation.ListView = Em.View.extend({
    templateName: "views_relation_list"
  });
  app.Relation.ShowView = Em.View.extend({
    templateName: "views_relation_show",
    "delete": function(e) {
      return this.get('relation')["delete"]();
    }
  });
  window.findNestedProp = function(obj, prop) {
    var k, v, _results;
    if (_.isFunction(obj) || _.isNumber(obj) || _.isString(obj) || isBlank(obj)) {
      return;
    }
    console.debug(obj);
    _results = [];
    for (k in obj) {
      v = obj[k];
      if (k === prop) {
        console.debug("found " + prop);
      }
      _results.push(isPresent(v) && v !== obj ? findNestedProp(v, prop) : void 0);
    }
    return _results;
  };
}).call(this);
