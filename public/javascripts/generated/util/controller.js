(function() {
  var MyArrayController, app, fixHashDates, h, k, v, withCachedAndLive;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  app = window.App;
  withCachedAndLive = function(ops) {
    var doCache, res;
    doCache = $ && $.jStorage && ops.cacheName;
    if (doCache) {
      res = $.jStorage.get(ops.cacheName);
      if (res) {
        console.debug("with cache " + ops.cacheName);
        ops.callback(res);
      }
    }
    return ops.getLive(function(data) {
      mySetTimeout(function() {
        console.debug("setting cache " + ops.cacheName);
        if (doCache) {
          $.jStorage.set(ops.cacheName, data);
        }
        return console.debug("set cache " + ops.cacheName);
      }, 5000);
      console.debug("with live " + ops.cacheName);
      return ops.callback(data);
    });
  };
  window.MyArrayController = MyArrayController = Ember.ArrayController.extend({
    content: [],
    whenLoadedFuncs: [],
    loadFromJson: function(ff) {
      return this.withAll(__bind(function(all) {
        var obj, _i, _len;
        this.set('content', []);
        for (_i = 0, _len = all.length; _i < _len; _i++) {
          obj = all[_i];
          if (obj.afterCreate) {
            obj.afterCreate();
          }
          this.pushObject(obj);
        }
        this.loaded = true;
        this.afterLoaded();
        if (ff) {
          console.debug('ff');
          return ff();
        }
      }, this));
    },
    whenLoaded: function(cb) {
      this.whenLoadedFuncs.push(cb);
      if (this.loaded) {
        return cb();
      }
    },
    afterLoaded: function() {
      var f, _i, _len, _ref;
      _ref = this.whenLoadedFuncs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        f();
      }
      return MyArrayController.allLoadedCheck();
    }
  }, fixHashDates = function(h) {
    var k, v;
    for (k in h) {
      v = h[k];
      if (v && v[0] === 'Time') {
        h[k] = new Date(v[1], v[2] - 1, v[3], v[4], v[5], v[6]);
      }
    }
    return h;
  }, {
    rawToObjs: function(raw) {
      var objs;
      raw = _.map(raw, fixHashDates);
      objs = _.map(raw, __bind(function(obj) {
        return this.modelClass.create(obj);
      }, this));
      objs = _.sortBy(objs, function(obj) {
        return obj.sortName();
      });
      if (this.modelClass.sortReverse) {
        objs = objs.reverse();
      }
      return objs;
    },
    withAll: function(f) {
      return withCachedAndLive({
        cacheName: this.get('controllerName'),
        getLive: this.getRawJson,
        callback: __bind(function(raw) {
          this.all = this.rawToObjs(raw);
          return f(this.all);
        }, this)
      });
    }
  });
  h = {
    controllers: [],
    whenLoadedFuncs: [],
    myCreate: function(h) {
      var res;
      res = this.create(h);
      res.set('content', []);
      mySetTimeout(function() {
        return res.loadFromJson();
      }, 100 + Math.random() * 100);
      this.controllers.push(res);
      return res;
    },
    areAllLoaded: function() {
      return _.all(this.controllers, function(c) {
        return c.loaded;
      });
    },
    whenAllLoaded: function(f) {
      this.whenLoadedFuncs.push(f);
      if (this.areAllLoaded()) {
        return f();
      }
    },
    allLoadedCheck: function() {
      var f, _i, _len, _ref, _results;
      if (this.areAllLoaded()) {
        _ref = this.whenLoadedFuncs;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          f = _ref[_i];
          _results.push(f());
        }
        return _results;
      }
    }
  };
  for (k in h) {
    v = h[k];
    MyArrayController[k] = v;
  }
}).call(this);
