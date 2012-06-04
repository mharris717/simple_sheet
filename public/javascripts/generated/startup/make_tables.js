(function() {
  var app, makePresidentsTable;
  app = window.App;
  window.makeFreshTable = function() {
    var k, t, v, _ref;
    t = app.Table.create({
      name: 'stats'
    });
    _ref = {
      bavg: "=h/ab",
      ab: "=pa-bb",
      tb: "=h+b2+b3*2+hr*3",
      obp: "=(bb+h)/pa",
      slg: "=tb/ab",
      ops: "=obp+slg"
    };
    for (k in _ref) {
      v = _ref[k];
      t.setFormula(k, v);
    }
    t.addRow({
      name: 'Ted Williams',
      year: 1955,
      pa: 600,
      h: 165,
      b2: 30,
      b3: 2,
      hr: 15,
      bb: 75
    });
    t.addRow({
      name: 'Ted Williams',
      year: 1956,
      pa: 600,
      h: 165,
      b2: 30,
      b3: 2,
      hr: 25,
      bb: 75
    });
    t.addRow({
      name: 'Babe Ruth',
      year: 1927,
      pa: 600,
      h: 165,
      b2: 30,
      b3: 2,
      hr: 55,
      bb: 75
    });
    t.addRelation("players", "$players.name == $stats.name");
    return t;
  };
  window.makePlayersTable = function() {
    var t;
    t = app.Table.create({
      name: 'players'
    });
    t.setFormula("hr", "=$stats.hr");
    t.addRow({
      name: 'Ted Williams',
      side: 'L'
    });
    t.addRow({
      name: 'Babe Ruth',
      side: 'R'
    });
    return t;
  };
  window.makeWidgetTable = function() {
    var t;
    t = app.Table.create({
      name: 'widgets'
    });
    t.addRow({
      name: 'Elmo',
      dept: 'Toys',
      price: 20
    });
    t.addRow({
      name: 'Nintendo',
      dept: 'Toys',
      price: 200
    });
    t.addRow({
      name: 'Lawnmower',
      dept: 'Lawn',
      price: 500
    });
    t.addRelation("depts", "$widgets.dept == $depts.name");
    return t;
  };
  window.makeDeptTable = function() {
    var t;
    t = app.Table.create({
      name: 'depts'
    });
    t.setFormula('psum', '=$widgets.price');
    t.addRow({
      name: 'Toys',
      min_prc: 50
    });
    t.addRow({
      name: 'Lawn',
      min_prc: 100
    });
    return t;
  };
  window.makeLoadTable = function() {
    var t;
    t = app.Table.create({
      name: 'loaded'
    });
    t.loadCSV("a,b,c\n1,2,3");
    t.loadCSV("a,b,z\n4,5,6");
    return t;
  };
  makePresidentsTable = function() {
    var t;
    t = app.Table.create({
      name: 'presidents'
    });
    return t;
  };
  window.getNamedTable = function(name) {
    var map, obj;
    map = {
      stats: makeFreshTable,
      players: makePlayersTable,
      widgets: makeWidgetTable,
      depts: makeDeptTable,
      load: makeLoadTable,
      presidents: makePresidentsTable
    };
    obj = SimpleSave.load(App.Table, name, {
      allowMissing: true
    });
    if (!obj) {
      obj = map[name]();
      setTimeout(function() {
        return SimpleSave.save(obj);
      }, 500);
    } else {

    }
    return obj;
  };
}).call(this);
