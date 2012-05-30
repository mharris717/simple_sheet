(function() {
  var VolitileObserve, checkMethPresence;
  checkMethPresence = function(cls, meth) {
    var f, obj, objs, res, str, strs, type, val;
    res = {};
    strs = [];
    objs = {
      klass: cls,
      obj: cls.create(),
      pro: cls.prototype,
      objPro: cls.create().prototype
    };
    for (type in objs) {
      obj = objs[type];
      if (obj) {
        console.debug(type);
        console.debug(obj);
        f = obj[meth];
        res["" + type + " basic"] = f;
        res["" + type + " invoked"] = f && f.call ? f.call() : void 0;
        res["" + type + " get"] = obj.get ? obj.get(meth) : void 0;
        res["" + type + " keys"] = _.keys(obj).sort();
      }
    }
    for (type in res) {
      val = res[type];
      str = "" + type + ": " + val;
      strs.push(str);
      console.debug(str);
    }
    return strs.join("\n");
  };
  VolitileObserve = Ember.Mixin.create({
    setupVolitileObservers: function() {
      var info, prop, target, _i, _j, _len, _len2, _ref, _ref2, _results;
      info = this.volitileSetupInfo();
      _ref = info.targets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        target = _ref[_i];
        target.obj.addObserver(target.property, this, target.callback);
      }
      _ref2 = info.watch;
      _results = [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        prop = _ref2[_j];
        _results.push(this.addObserver(prop, this, this.setupVolitileObservers));
      }
      return _results;
    }
  });
  window.Person = Em.Object.extend(VolitileObserve, {
    init: function() {
      if (!this.get('name')) {
        return this.set('name', 'Adam');
      }
    },
    doubleName: (function() {
      return "" + (this.get('name')) + (this.get('name'));
    }).property('name')
  });
  describe('observer testing', function() {
    var adam, brian, chris, list, setupList;
    list = adam = brian = chris = null;
    setupList = function() {
      list = Em.ArrayController.create({
        content: []
      });
      list.pushObject(Person.create({
        name: 'Adam'
      }));
      list.pushObject(Person.create({
        name: 'Brian'
      }));
      list.pushObject(Person.create({
        name: 'Chris'
      }));
      adam = list.get('content')[0];
      brian = list.get('content')[1];
      return chris = list.get('content')[2];
    };
    beforeEach(function() {
      return setupList();
    });
    it("should observe - simple", function() {
      var f, val;
      val = 0;
      f = function() {
        return val += 1;
      };
      adam.addObserver('name', this, f);
      adam.set('name', 'Steve');
      return expect(val).toEqual(1);
    });
    it("should observe - all", function() {
      var f, val;
      val = 0;
      f = function() {
        return val += 1;
      };
      list.addObserver('@each.name', this, f);
      adam.set('name', 'Steve');
      return expect(val).toEqual(1);
    });
    it("should observe - all2", function() {
      var f, val;
      val = 0;
      f = function() {
        return val += 1;
      };
      list.addObserver('@each.name', this, f);
      adam.set('name', 'Steve');
      list.pushObject(Em.Object.create({
        name: 'Chris'
      }));
      return expect(val).toEqual(2);
    });
    it('prop stuff', function() {
      var res;
      return res = checkMethPresence(Person, 'doubleName');
    });
    return describe('volitile', function() {
      var callCount;
      callCount = null;
      beforeEach(function() {
        var cb, obj, _i, _len, _ref, _results;
        callCount = 0;
        cb = function() {
          return callCount += 1;
        };
        Person.reopen({
          volitileSetupInfo: function() {
            var res;
            res = {
              targets: [],
              watch: ['name']
            };
            if (this.get('name').match(/^B/)) {
              res.targets = [
                {
                  obj: adam,
                  property: 'name',
                  callback: cb
                }
              ];
            }
            return res;
          }
        });
        setupList();
        _ref = list.get('content');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          obj = _ref[_i];
          _results.push(obj.setupVolitileObservers());
        }
        return _results;
      });
      it('changing adam calls cb', function() {
        adam.set('name', 'Dave');
        return expect(callCount).toEqual(1);
      });
      it('changing brian does nothing', function() {
        brian.set('name', 'Paul');
        return expect(callCount).toEqual(0);
      });
      it('changing chris to bob causes observers to be active', function() {
        chris.set('name', 'Bob');
        adam.set('name', 'Dave');
        return expect(callCount).toEqual(2);
      });
      return it('changing brian to bob leaves only 1 observer', function() {
        brian.set('name', 'Bob');
        adam.set('name', 'Dave');
        return expect(callCount).toEqual(1);
      });
    });
  });
}).call(this);
