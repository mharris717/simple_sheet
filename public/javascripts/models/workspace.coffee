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

window.getWorkspace = ->
  w = app.Workspace.create()
  w.addTable makeFreshTable()
  w.addTable makeWidgetTable()
  w
