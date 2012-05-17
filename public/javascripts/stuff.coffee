app = window.App

app.Table = Ember.Object.extend
  init: ->
    @set('rows',Ember.ArrayController.create(content: []))
    @set('formulas',{})
    
  fields: (->
    res = {}
    for row in @$rows.$content
      for own k,v of row
        if k != '_super' && k != 'table'
          res[k] = true 
    _.keys(res)).property('rows.@each')
  
  addRow: (h) ->
    h[k] ||= null for k,v of @$formulas
    row = app.Row.create(h)
    row.set('table',this)
    @$rows.pushObject(row)

    
app.Row = Ember.Object.extend
  init: ->
    logger.log 'made a row'
    
  fieldsBinding: "table.fields"
  
  cells: (->
    for k in @$fields
      res = app.Cell.create(field: k, row: this)
      res).property('fields').cacheable()

  cellForField: (f) ->
    @$cells.filter( (cell) -> cell.$field == f )[0]
      
  evalInContext: (rawStr) ->
    logger.debug "evalInContext #{rawStr}"
    str = rawStr
    for cell in @$cells
      f = cell.$field
      if str.match("{{#{f}}}")
        val = cell.$value
        str = str.replace("{{#{f}}}",val)
      if str.match(f)
        val = cell.$value
        str = str.replace(f,val)
    res = null
    try
      res = eval(str)
    catch error
      res = "eval error for #{rawStr} -> #{str}"

    logger.log "evaled #{rawStr} -> #{str} -> #{res}"
    res
      
t = app.Table.create()
t.set('formulas',{ab: "=pa-bb", tb: "=h+b2+b3*2+hr*3", obp: "=(bb+h)/pa", slg: "=tb/ab", ops: "=obp+slg"})

t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 15, bb: 75)
t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 25, bb: 75)

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
  valueBinding: "cell.value"
  rawValueBinding: "cell.rawValue"

  editing: false
  
  click: (e) ->
    @set('editing',true)
    setTimeout ->
      @.$('input').focus()
    ,100
    
  focusOut: (e) -> 
    @set('editing',false)
  
v = app.MainView.create()
$ -> v.append()
