(function() {
  var app, getPersistanceManagerPrototype, persistanceManagerPrototype;
  app = window.App;
  window.SimpleSave = {};
  SimpleSave.PersistedHash = function(ops) {
    var funcs, k, res, v;
    funcs = {
      get: function(k) {
        return this.getHash()[k];
      },
      set: function(k, v) {
        this.getHash()[k] = v;
        return this.save();
      },
      "delete": function(k) {
        delete this.getHash[k];
        return this.save();
      },
      save: function() {
        return $.jStorage.set(this.key, this.getHash());
      },
      getHash: function() {
        if (this.loaded) {
          return this.loadedHash;
        } else {
          this.loaded = true;
          return this.loadedHash = $.jStorage.get(this.key) || {};
        }
      },
      clear: function() {
        this.loadedHash = {};
        this.loaded = true;
        return this.save();
      },
      size: function() {
        return this.keys().length;
      },
      keys: function() {
        return _.keys(this.getHash());
      }
    };
    res = {};
    res.key = ops.key;
    for (k in funcs) {
      v = funcs[k];
      res[k] = v;
    }
    return res;
  };
  persistanceManagerPrototype = null;
  getPersistanceManagerPrototype = function() {
    var pmp;
    if (!persistanceManagerPrototype) {
      pmp = persistanceManagerPrototype = {};
      pmp.save = function(obj) {
        var key, raw;
        key = this.prefix + "-" + obj.saveName();
        raw = this.objToJson.apply(obj);
        $.jStorage.set(key, raw);
        return this.addKey(key);
      };
      pmp.load = function(objName, ops) {
        var key, obj, raw;
        if (isBlank(ops)) {
          ops = {};
        }
        key = ops.alreadyPrefixed ? objName : this.prefix + "-" + objName;
        raw = $.jStorage.get(key);
        if (isBlank(raw)) {
          if (ops.allowMissing) {
            return;
          } else {
            logger.log("no saved object found for " + key);
            throw "no saved object found for " + key;
          }
        }
        obj = this.objClass.create();
        if (isPresent(raw)) {
          this.objHydrate.apply(obj, [raw]);
        }
        return obj;
      };
      pmp.addKey = function(key) {
        if (!this.keyHash.get(key)) {
          return this.keyHash.set(key, true);
        }
      };
      pmp.removeKey = function(key) {
        if (this.keyHash.get(key)) {
          return this.keyHash["delete"](key);
        }
      };
      pmp.getKeys = function() {
        return this.keyHash.keys();
      };
      pmp.size = function() {
        return this.getKeys().length;
      };
      pmp.objToJson = function() {
        return this.toJson();
      };
      pmp.objHydrate = function(raw) {
        return this.hydrate(raw);
      };
      pmp.clear = function() {
        var k, _i, _len, _ref;
        _ref = this.keyHash.keys();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          k = _ref[_i];
          $.jStorage.deleteKey(k);
        }
        return this.keyHash.clear();
      };
      pmp.getAll = function() {
        var n, res, _i, _len, _ref;
        res = [];
        _ref = this.getKeys();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          res.push(this.load(n, {
            alreadyPrefixed: true
          }));
        }
        return res;
      };
    }
    return persistanceManagerPrototype;
  };
  SimpleSave.PersistanceManager = function(ops) {
    var k, res, v;
    res = Object.create(getPersistanceManagerPrototype());
    for (k in ops) {
      v = ops[k];
      res[k] = v;
    }
    res.keyHash = SimpleSave.PersistedHash({
      key: "" + ops.prefix + "-keys"
    });
    return res;
  };
  SimpleSave.PersistanceManager.getManagerForObj = function(obj) {
    var key;
    this.managerHash || (this.managerHash = {});
    key = obj.__proto__.constructor;
    return this.getManagerForClass(key);
  };
  SimpleSave.PersistanceManager.getManagerForClass = function(klass) {
    var _base;
    this.managerHash || (this.managerHash = {});
    (_base = this.managerHash)[klass] || (_base[klass] = SimpleSave.PersistanceManager({
      prefix: "" + klass,
      objClass: klass
    }));
    return this.managerHash[klass];
  };
  SimpleSave.PersistanceManager.save = function(obj) {
    return this.getManagerForObj(obj).save(obj);
  };
  SimpleSave.PersistanceManager.load = function(klass, key, ops) {
    return this.getManagerForClass(klass).load(key, ops);
  };
  SimpleSave.load = function(a, b, c) {
    return SimpleSave.PersistanceManager.load(a, b, c);
  };
  SimpleSave.save = function(a, b, c) {
    return SimpleSave.PersistanceManager.save(a, b, c);
  };
  if (false) {
    window.SaveableObject = Ember.Object.extend({
      save: function() {
        var name, raw;
        raw = this.toJson();
        name = "table-" + this.get('saveName');
        return $.jStorage.set(name, raw);
      }
    });
    window.Animal = Ember.Object.extend({
      a: 1
    });
    Animal.myExtend = function(ops) {
      var res;
      res = this.extend(ops);
      res.make = function() {
        return this.create();
      };
      return res;
    };
    window.Cat = Animal.myExtend({
      a: 2
    });
    Animal.make = function() {
      return this.create();
    };
  }
}).call(this);
