app.Workspace = Em.Object.extend
  init: ->
    @set 'tables',Em.ArrayController.create(content: [])

  addTable: (t) -> 
    t.set 'workspace', this
    @$tables.pushObject(t)

  getTable: (n) ->
    res = @$tables.$content.filter((obj) -> obj.$name == n)[0]
    throw "no table #{n}" unless res
    res

  fields: (->
    res = @$tables.map((t) -> t.$fields)
    res = _.flatten(res)
    _.uniq(res)).property('tables.@each.fields')

  setupAll: ->
    for table in @$tables
      table.setupAll()

window.getWorkspace = ->
  w = app.Workspace.create()
  w.addTable makeFreshTable()
  w.addTable makeWidgetTable()
  w.addTable makeDeptTable()
  w
