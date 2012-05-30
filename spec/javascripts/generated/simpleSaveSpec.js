(function() {
  describe('SimpleSave', function() {
    describe('persistedHash', function() {
      return it('smoke', function() {
        var h;
        h = SimpleSave.PersistedHash({
          key: 'testh'
        });
        h.clear();
        expect(h.size()).toEqual(0);
        h.set('foo', 14);
        expect(h.size()).toEqual(1);
        expect(h.get('foo')).toEqual(14);
        h = SimpleSave.PersistedHash({
          key: 'testh'
        });
        expect(h.size()).toEqual(1);
        return expect(h.get('foo')).toEqual(14);
      });
    });
    describe('Widget', function() {
      var Widget, pm, widget;
      Widget = pm = widget = null;
      beforeEach(function() {
        Widget = Em.Object.extend({
          toJson: function() {
            return {
              color: this.get('color')
            };
          },
          hydrate: function(raw) {
            return this.set('color', raw.color);
          },
          saveName: function() {
            return this.get('name');
          }
        });
        pm = SimpleSave.PersistanceManager({
          prefix: "foo",
          objClass: Widget
        });
        pm.clear();
        return widget = Widget.create({
          color: 'Blue',
          name: 'Gear'
        });
      });
      it('size', function() {
        expect(pm.size()).toEqual(0);
        pm.save(widget);
        expect(pm.size()).toEqual(1);
        pm = SimpleSave.PersistanceManager({
          prefix: "foo",
          objClass: Widget
        });
        return expect(pm.size()).toEqual(1);
      });
      return it('size2', function() {
        SimpleSave.PersistanceManager.getManagerForObj(widget).clear();
        SimpleSave.PersistanceManager.save(widget);
        widget = SimpleSave.PersistanceManager.load(Widget, 'Gear');
        return expect(widget.get('color')).toEqual('Blue');
      });
    });
    return describe('Table', function() {
      var manager, table;
      table = manager = null;
      beforeEach(function() {
        getWorkspacesFresh();
        table = getWorkspaces()[0].getTable('stats');
        manager = SimpleSave.PersistanceManager.getManagerForObj(table);
        return manager.clear();
      });
      it('smoke', function() {
        console.debug("manager " + manager);
        manager.save(table);
        return expect(2).toEqual(2);
      });
      return it('smoke 2', function() {
        var t;
        manager.save(table);
        t = manager.load('stats');
        return expect(t.get('rows').get('content').length).toEqual(3);
      });
    });
  });
}).call(this);
