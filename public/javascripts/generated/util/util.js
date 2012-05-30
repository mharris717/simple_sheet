(function() {
  var app, getRemoteJsonInner;
  app = window.App;
  window.Memoize = {
    logs: {},
    print: function() {
      var f, log, _ref, _results;
      _ref = this.logs;
      _results = [];
      for (f in _ref) {
        log = _ref[f];
        _results.push(console.debug("" + log.name + " " + log.count + " " + log.freshCount));
      }
      return _results;
    },
    memoize: function(f, n) {
      var log;
      log = this.logs[f] = {
        count: 0,
        freshCount: 0,
        results: {},
        ran: {},
        name: n
      };
      return function(arg) {
        var fresh;
        log.count += 1;
        if (log.ran[arg]) {
          return log.results[arg];
        } else {
          fresh = f(arg);
          log.freshCount += 1;
          log.results[arg] = fresh;
          log.ran[arg] = true;
          return fresh;
        }
      };
    }
  };
  Function.prototype.memoized = function(n) {
    return Memoize.memoize(this, n);
  };
  jQuery.ajaxSetup({
    async: true
  });
  getRemoteJsonInner = function(url, f, retryOnError) {
    var res;
    if (retryOnError == null) {
      retryOnError = true;
    }
    res = null;
    $.ajax({
      url: url,
      dataType: 'json',
      type: 'GET',
      success: function(data) {
        res = data;
        return f(data);
      },
      error: function(data) {
        if (retryOnError) {
          return mySetTimeout(function() {
            return getRemoteJsonInner(url, f, false);
          }, Math.random() * 1500);
        } else {
          return f([]);
        }
      }
    });
    return res;
  };
  window.getRemoteJson = function(url, f) {
    return getRemoteJsonInner(url, function(data) {
      return f(data);
    });
  };
  window.smeDebug = function(str) {
    var s;
    s = str;
    return console.debug(str);
  };
  Date.prototype.prettyStr = function() {
    var h, m, res;
    res = "" + (this.getMonth() + 1) + "/" + (this.getDate()) + " ";
    h = this.getHours();
    m = this.getMinutes();
    if (m < 10) {
      m = "0" + m;
    }
    res += "" + h + ":" + m;
    return res;
  };
  String.prototype.toDate = function() {
    var res;
    res = this.match("([0-9]{4})-([0-9]{2})-([0-9]{2})[T ]([0-9]{2}):([0-9]{2}):([0-9]{2})");
    if (res) {
      return new Date(res[1], res[2] - 1, res[3], res[4], res[5], res[6]);
    } else {
      return null;
    }
  };
  window.setTimeoutMultiple = function(f, times) {
    var t, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = times.length; _i < _len; _i++) {
      t = times[_i];
      _results.push(setTimeout(f, t));
    }
    return _results;
  };
  Handlebars.registerHelper('prettyDate', function(prop) {
    var value;
    value = Ember.getPath(this, prop);
    if (value && value.toDate) {
      value = value.toDate() || value;
    }
    if (value && value.prettyStr) {
      value = value.prettyStr();
    }
    if (!value) {
      value = '';
    }
    return new Handlebars.SafeString(value);
  });
  Handlebars.registerHelper('deferView', function(prop) {
    window.MyArrayController.whenAllLoaded(function() {
      var div;
      div = App.mainView.$("#table-div");
      App.mainView.tablesView = App.tablesView.create({
        tablesBinding: "App.tables"
      });
      return App.mainView.tablesView.appendTo(div);
    });
    return "";
  });
  Handlebars.registerHelper('mapBool', function(prop, true_val, false_val) {
    var res, val;
    if (!_.isString(false_val)) {
      false_val = '';
    }
    val = Ember.getPath(this, prop);
    res = val === true ? true_val : val === false ? false_val : val;
    return new Handlebars.SafeString(res);
  });
  Handlebars.registerHelper('makeTable', function(band) {
    var f, fieldMap, fields, res, rows, val, _i, _len;
    val = Ember.getPath(this, "fullName");
    band = this.band;
    fields = band.get('rowKeys');
    rows = band.get('rows');
    res = "<table class='main'><tr>";
    fieldMap = {
      batting_team_city: 'city',
      league_level: 'level',
      batting_team_abbr: 'abbr'
    };
    for (_i = 0, _len = fields.length; _i < _len; _i++) {
      f = fields[_i];
      res += "<th>" + ((fieldMap[f] || f).camelize()) + "</th>";
    }
    res += "</tr>";
    _.each(rows, function(row) {
      var f, _i, _len;
      res += "<tr>";
      for (_i = 0, _len = fields.length; _i < _len; _i++) {
        f = fields[_i];
        res += "<td>" + (row[f] || ' ') + "</td>";
      }
      return res += "</tr>";
    });
    res += "</table>";
    return new Handlebars.SafeString(res);
  });
  String.prototype.myGsub = function(pattern, str) {
    var new_str, res;
    res = "dfgdfgdfg";
    new_str = this;
    while (res !== new_str) {
      res = new_str;
      new_str = new_str.replace(pattern, str);
    }
    return new_str;
  };
  _.join = function(a, sep) {
    var f, i, obj, res, _i, _len;
    res = "";
    i = 0;
    f = function(obj) {
      if (i !== 0) {
        res += sep;
      }
      res += obj;
      return i += 1;
    };
    for (_i = 0, _len = a.length; _i < _len; _i++) {
      obj = a[_i];
      f(obj);
    }
    return res;
  };
  window.regTest = function() {
    var reg, res, str;
    str = "2012-04-25T13:49:42-04:00";
    reg = "([0-9]{4})-([0-9]{2})-([0-9]{2})";
    res = str.match(reg);
    console.debug(res);
    return res;
  };
  window.onlyOnceFunc = function(f) {
    var times;
    times = 0;
    return function() {
      if (times === 0) {
        f();
      }
      return times += 1;
    };
  };
  window.isBlank = (function(obj) {
    if (!obj) {
      return true;
    } else if (obj === '') {
      return true;
    } else if (obj.trim && obj.trim() === '') {
      return true;
    } else {
      return false;
    }
  }).memoized('isBlank');
  window.isPresent = function(obj) {
    return !isBlank(obj);
  };
  window.mySetTimeout = function(a, b) {
    var func, time;
    func = time = null;
    if (_.isFunction(a)) {
      func = a;
      time = b;
    } else if (_.isFunction(b)) {
      func = b;
      time = a;
    } else {
      sfgdfgdfg;
    }
    if (testMode) {
      logger.log("doing func in timeout " + time);
      return func();
    } else {
      return setTimeout(func, time);
    }
  };
  String.prototype.scan = function(reg, pos) {
    var i, res;
    pos || (pos = 0);
    if (!reg.exec) {
      reg = new RegExp(reg);
    }
    res = reg.exec(this, pos);
    if (res) {
      i = res.index + res[0].length + 1;
      if (i === pos) {
        throw "same index " + i + " res " + res + " this " + this + " reg " + reg;
      }
      if (i >= this.length) {
        return [res[0]];
      } else {
        return [res[0]].concat(this.substr(i, 999).scan(reg));
      }
    } else {
      return [];
    }
  };
}).call(this);
