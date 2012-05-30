describe 'SimpleSave', ->
  describe 'persistedHash', ->
    it 'smoke', ->
      h = SimpleSave.PersistedHash(key: 'testh')
      h.clear()
      expect(h.size()).toEqual(0)
      h.set 'foo', 14
      expect(h.size()).toEqual(1)
      expect(h.get('foo')).toEqual(14)

      h = SimpleSave.PersistedHash(key: 'testh')
      expect(h.size()).toEqual(1)
      expect(h.get('foo')).toEqual(14)


  describe 'Widget', ->
    Widget = pm = widget = null
    beforeEach ->
      Widget = Em.Object.extend
        toJson: ->
          {color: @$color}

        hydrate: (raw) ->
          @set 'color', raw.color

        saveName: -> @$name

      pm = SimpleSave.PersistanceManager
        prefix: "foo"
        objClass: Widget

      pm.clear()

      widget = Widget.create(color: 'Blue', name: 'Gear')

    it 'size', ->
      expect(pm.size()).toEqual(0)
      pm.save(widget)
      expect(pm.size()).toEqual(1)
      pm = SimpleSave.PersistanceManager
        prefix: "foo"
        objClass: Widget
      expect(pm.size()).toEqual(1)
      
    it 'size2', ->
      SimpleSave.PersistanceManager.getManagerForObj(widget).clear()
      SimpleSave.PersistanceManager.save(widget)
      widget = SimpleSave.PersistanceManager.load(Widget,'Gear')
      expect(widget.$color).toEqual('Blue')

  describe 'Table', ->
    table = manager = null
    beforeEach ->
      getWorkspacesFresh()

      table = getWorkspaces()[0].getTable('stats')
      manager = SimpleSave.PersistanceManager.getManagerForObj(table)

      manager.clear()

    it 'smoke', ->
      console.debug "manager #{manager}"
      manager.save(table)
      expect(2).toEqual(2)

    it 'smoke 2', ->
      manager.save(table)
      t = manager.load('stats')
      expect(t.$rows.$content.length).toEqual(3)