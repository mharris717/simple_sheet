window.App ||= Ember.Application.create()
app = window.App

app.Table = Ember.Object.extend
  init: ->
    @set('rows',Ember.ArrayController.create(content: []))
    
  fields: (->
    res = {}
    for row in @get('rows').get('content')
      for own k,v of row
        if k != '_super' && k != 'table'
          res[k] = true 
    _.keys(res)).property('rows.@each')
  
  addRow: (h) ->
    row = app.Row.create(h)
    row.set('table',this)
    @get('rows').pushObject(row)
    
app.Row = Ember.Object.extend
  init: ->
    console.debug 'made a row'
  
  values: (->
    console.debug 'in values'
    @get(k) || '' for k in @get('table').get('fields')).property('table.fields')
  
    
t = app.Table.create()
t.addRow {a: 1, b: 2}
t.addRow {a: 14, c: 21}

setTimeout ->
  t.addRow {d: 24}
,2000

app.set 'table', t

app.MainView = Ember.View.extend
  templateName: "views_main"
  tableBinding: "App.table"
  
app.RowView = Ember.View.extend
  templateName: "views_row"
  

  
app.NullView = Ember.View.extend
  templateName: "views_null"
  
app.CatView = Ember.View.extend
  templateName: "views_cat"
  
app.CellView = Ember.View.extend
  templateName: "views_cell"
  
  value: (-> 14).property()

  editing: false
  
  click: (e) ->
    console.debug "cell click " + @get('value')
    @set('editing',true)
  
v = app.MainView.create()
$ -> v.append()
