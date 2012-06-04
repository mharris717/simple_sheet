(function() {
  var app;
  app = window.App;
  Array.prototype.max = function() {
    var obj, res, _i, _len;
    res = this[0];
    if (this.length === 0) {
      return res;
    }
    if (this.length === 1) {
      return this[0];
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      if (obj) {
        obj = parseFloat(obj);
      }
      if (!res) {
        res = obj;
      } else if (obj && obj > res) {
        res = obj;
      }
    }
    return res;
  };
  Array.prototype.min = function() {
    var obj, res, _i, _len;
    res = this[0];
    if (this.length === 0) {
      return res;
    }
    if (this.length === 1) {
      return this[0];
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      if (obj) {
        obj = parseFloat(obj);
      }
      if (!res) {
        res = obj;
      } else if (obj && obj < res) {
        res = obj;
      }
    }
    return res;
  };
  Array.prototype.avg = function() {
    var obj, res, _i, _len;
    if (this.length === 0) {
      return 0;
    }
    res = 0;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      if (obj) {
        res += parseFloat(obj);
      }
    }
    return res / this.length;
  };
  Array.prototype.sum = function() {
    var obj, res, _i, _len;
    if (this.length === 0) {
      return 0;
    }
    res = 0;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      obj = this[_i];
      if (obj) {
        res += parseFloat(obj);
      }
    }
    return res;
  };
}).call(this);
