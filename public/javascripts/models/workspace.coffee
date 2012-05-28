app.Workspace = Em.Object.extend
  init: ->
    @set 'tables',Em.ArrayController.create(content: [])

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
    for table in @$tables
      table.setupAll()



window.getWorkspaces = ->
  w = app.Workspace.create(name: 'Baseball')
  w.addTable makeFreshTable()
  w.addTable makePlayersTable()

  w2 = app.Workspace.create(name: 'WidgetCorp')
  w2.addTable makeWidgetTable()
  w2.addTable makeDeptTable()
  
  [w,w2]

app.set 'workspaces', Em.ArrayController.create
  content: getWorkspaces()