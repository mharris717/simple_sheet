app.Workspace = Em.Object.extend
  init: ->
    @set 'tables',Em.ArrayController.create(content: [])

  saveName: -> @$name

  addTable: (t) -> 
    t.set 'workspace', this
    @$tables.pushObject(t)

  removeTable: (t) ->
    @$tables.removeObject(t)

  newTable: ->
    t = app.Table.create()
    #t.addRow {a: 2}
    @addTable(t)

  getTable: (n,safe=true) ->
    res = @$tables.$content.filter((obj) -> obj.$name == n)[0]
    throw "no table #{n}" if !res && safe
    res

  fields: (->
    res = @$tables.map((t) -> t.$fields)
    res = _.flatten(res)
    _.uniq(res)).property('tables.@each.fields')

  setupAll: ->
    for table in @$tables.$content
      table.setupAll()

  toJson: ->
    res = {}
    res.name = @$name
    res.tables = @$tables.map (t) -> t.$name
    res

  hydrate: (raw) ->
    @set 'name', raw.name
    for name in raw.tables
      @addTable SimpleSave.load(App.Table,name)

  save: ->
    SimpleSave.save(this)
    for t in @$tables.$content
      SimpleSave.save(t)



window.getWorkspacesFresh = ->
  $.jStorage.flush()
  w = app.Workspace.create(name: 'Baseball')
  w.addTable getNamedTable('stats')
  w.addTable getNamedTable('players')
  w.save()

  w2 = app.Workspace.create(name: 'WidgetCorp')
  w2.addTable getNamedTable('widgets')
  w2.addTable getNamedTable('depts')
  w2.addTable getNamedTable('load')
  w2.save()

  w3 = app.Workspace.create(name: 'Presidents')
  w3.addTable getNamedTable('presidents')
  w3.save()
  
  
  [w,w2,w3]

ensureWorkspacesExist = (f) ->
  res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll()
  if res.length == 0
    setTimeout ->
      $('body').text('Initializing.')
      setInterval ->
        $('body').append(".")
      ,1000
      getWorkspacesFresh() 
      res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll()
      setTimeout ->
        location.reload()
      ,6000
      f(res)
    ,1000
  else
    f(res)

window.getWorkspaces = ->
  res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll()
  if res.length == 0
    getWorkspacesFresh() 
    res = SimpleSave.PersistanceManager.getManagerForClass(App.Workspace).getAll()
  res


app.set 'workspaces', Em.ArrayController.create
  content: []
  getWorkspace: (name) ->
    @$content.filter((w) -> w.$name == name)[0]

  makeFresh: ->
    @set 'current', null
    setTimeout ->
      getWorkspacesFresh()
      setTimeout ->
        location.reload()
      ,1300
    ,2000

ensureWorkspacesExist (ws) -> app.workspaces.set 'content', ws

window.saveCurrentBackground = ->
  n = $.jStorage.get('current-workspace')
  if n
    w = app.workspaces.getWorkspace(n)
    app.workspaces.set('current',w)

  setInterval ->
    w = App.workspaces.get('current')
    if w
      w.save()
      $.jStorage.set('current-workspace',w.$name)
  ,1200

saveCurrentBackground()