(function() {
  var app, baseObjProps;
  app = window.App;
  Em.Object.prototype.safeGet = function(k) {
    var res;
    res = this.get(k);
    if (!res) {
      throw "get for " + k + " returned null for " + this;
    }
    return res;
  };
  Em.ArrayController.reopen({
    toJson: function() {
      return _.map(this.get('content'), function(obj) {
        if (obj.toJson) {
          return obj.toJson();
        } else {
          return obj;
        }
      });
    }
  });
  baseObjProps = function() {
    var k, res, v, _ref;
    res = {};
    _ref = Em.Object.create();
    for (k in _ref) {
      v = _ref[k];
      res[k] = true;
    }
    return res;
  };
  Em.Object.reopen({
    myProperties: function() {
      var base, isGood, k, res, v;
      base = baseObjProps();
      isGood = function(k, v) {
        if (base[k]) {
          return false;
        }
        if (_.isFunction(v)) {
          return false;
        }
        if (v === void 0) {
          return false;
        }
        if (k === 'row' || k === 'table' || k === 'baseTable' || k === 'workspace' || k === 'toJson') {
          return false;
        }
        return true;
      };
      res = [];
      for (k in this) {
        v = this[k];
        if (isGood(k, v)) {
          res.push(k);
        }
      }
      return res;
    },
    toJson: function(ops) {
      var prop, res, val, _base, _i, _len, _ref;
      res = {};
      _ref = this.myProperties();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        window.propCalls || (window.propCalls = {});
        (_base = window.propCalls)[prop] || (_base[prop] = 0);
        window.propCalls[prop] += 1;
        val = this.get(prop);
        if (val.toJson) {
          val = val.toJson();
        }
        res[prop] = val;
      }
      return res;
    }
  });
}).call(this);
