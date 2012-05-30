(function() {
  var app, ensureWorkspacesExist;
  app = window.App;
  app.Workspace = Em.Object.extend({
    init: function() {
      return this.set('tables', Em.ArrayController.create({
        content: []
      }));
    },
    saveName: function() {
      return this.get('name');
    },
    addTable: function(t) {
      t.set('workspace', this);
      return this.get('tables').pushObject(t);
    },
    removeTable: function(t) {
      return this.get('tables').removeObject(t);
    },
    newTable: function() {
      var t;
      t = app.Table.create();
      return this.addTable(t);
    },
    getTable: function(n, safe) {
      var res;
      if (safe == null) {
        safe = true;
      }
      res = this.get('tables').get('content').filter(function(obj) {
        return obj.get('name') === n;
      })[0];
      if (!res && safe) {
        throw "no table " + n;
      }
      return res;
    },
    fields: (function() {
      var res;
      res = this.get('tables').map(function(t) {
        return t.get('fields');
      });
      res = _.flatten(res);
      return _.uniq(res);
    }).property('tables.@each.fields'),
    setupAll: function() {
      var table, _i, _len, _ref, _results;
      _ref = this.get('tables').get('content');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        table = _ref[_i];
        _results.push(table.setupAll());
      }
      return _results;
    },
    toJson: function() {
      var res;
      res = {};
      res.name = this.get('name');
      res.tables = this.get('tables').map(function(t) {
        return t.get('name');
      });
      return res;
    },
    hydrate: function(raw) {
      var name, _i, _len, _ref, _results;
      this.set('name', raw.name);
      _ref = raw.tables;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        _results.push(this.addTable(SimpleSave.load(App.Table, name)));
      }
      return _results;
    },
    save: function() {
      var t, _i, _len, _ref, _results;
      SimpleSave.save(this);
      _ref = this.get('tables').get('content');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        _results.push(SimpleSave.save(t));
      }
      return _results;
    }
  });
  window.getWorkspacesFresh = function() {
    var w, w2, w3;
    $.jStorage.flush();
    w = app.Workspace.create({
      name: 'Baseball'
    });
    w.addTable(getNamedTable('stats'));
    w.addTable(getNamedTable('players'));
    w.save();
    w2 = app.Workspace.create({
      name: 'WidgetCorp'
    });
    w2.addTable(getNamedTable('widgets'));
    w2.addTable(getNamedTable('depts'));
    w2.addTable(getNamedTable('load'));
    w2.save();
    w3 = app.Workspace.create({
      name: 'Presidents'
    });
    w3.addTable(getNamedTable('presidents'));
    w3.save();
    return [w, w2, w3];
  };
  ensureWorkspacesExist = function(f) {
    var res;
    res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll();
    if (res.length === 0) {
      return setTimeout(function() {
        getWorkspacesFresh();
        res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll();
        setTimeout(function() {
          return location.reload();
        }, 600000);
        return f(res);
      }, 1000);
    } else {
      return f(res);
    }
  };
  window.getWorkspaces = function() {
    var res;
    res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll();
    if (res.length === 0) {
      getWorkspacesFresh();
      res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll();
    }
    return res;
  };
  app.set('workspaces', Em.ArrayController.create({
    content: [],
    getWorkspace: function(name) {
      return this.get('content').filter(function(w) {
        return w.get('name') === name;
      })[0];
    },
    makeFresh: function() {
      this.set('current', null);
      return setTimeout(function() {
        getWorkspacesFresh();
        return setTimeout(function() {
          return location.reload();
        }, 1300);
      }, 2000);
    }
  }));
  ensureWorkspacesExist(function(ws) {
    return app.workspaces.set('content', ws);
  });
  window.saveCurrentBackground = function() {
    var n, w;
    n = $.jStorage.get('current-workspace');
    if (n) {
      w = app.workspaces.getWorkspace(n);
      app.workspaces.set('current', w);
    }
    return setInterval(function() {
      w = App.workspaces.get('current');
      if (w) {
        w.save();
        return $.jStorage.set('current-workspace', w.get('name'));
      }
    }, 1200);
  };
  saveCurrentBackground();
}).call(this);
