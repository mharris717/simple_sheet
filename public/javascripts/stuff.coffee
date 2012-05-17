CoffeeScript

app = window.App

app.Table = Ember.Object.extend
  init: ->
    @set('rows',Ember.ArrayController.create(content: []))
    @set('formulas',Ember.Object.create())

  setFormula: (k,v) ->
    @$formulas.set(k,v)
    @$formulas.set('fields',{}) unless @$formulas.$fields
    @$formulas.$fields[k] = true
    
  fields: (->
    res = {}
    for row in @$rows.$content
      for own k,v of row
        if k != '_super' && k != 'table'
          res[k] = true 
    _.keys(res)).property('rows.@each')

  columns: (->
    app.Column.create(table: this, field: f) for f in @$fields).property('fields')
  
  addRow: (h) ->
    h[k] ||= null for k,v of @$formulas.$fields
    row = app.Row.create(h)
    row.set('table',this)
    @$rows.pushObject(row)

  setupAll: ->
    for row in @$rows.$content
      for cell in row.$cells
        cell.rawValueChanged()

    
app.Row = Ember.Object.extend
  init: ->
    logger.log 'made a row'
    
  fieldsBinding: "table.fields"
  
  cells: (->
    for k in @$table.$fields
      res = app.Cell.create(field: k, row: this)
      res).property('fields').cacheable()

  cellForField: (f) ->
    @$cells.filter( (cell) -> cell.$field == f )[0]

  multiEval: (str) ->
    try
      eval(str)
    catch error
      eval(CoffeeScript.compile("return #{str}"))
      
  evalInContext: (rawStr) ->
    logger.debug "evalInContext #{rawStr}"
    str = rawStr
    for cell in @$cells
      f = cell.$field
      if str.match("{{#{f}}}")
        val = cell.$value
        val = "'#{val}'" if val && val.match && val.match(new RegExp("[a-zA-Z]"))
        str = str.replace("{{#{f}}}",val)
    for cell in @$cells
      f = cell.$field
      if str.match(f)
        val = cell.$value
        val = "'#{val}'" if val && val.match && val.match(new RegExp("[a-zA-Z]"))
        str = str.replace(f,val)

    res = null
    try
      res = @multiEval(str)
    catch error
      res = "eval error for #{rawStr} -> #{str}"

    logger.log "evaled #{rawStr} -> #{str} -> #{res}"
    res

window.makeFreshTable = ->      
  t = app.Table.create()
  t.setFormula(k,v) for k,v of {bavg: "=h/ab", ab: "=pa-bb", tb: "=h+b2+b3*2+hr*3", obp: "=(bb+h)/pa", slg: "=tb/ab", ops: "=obp+slg"}

  t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 15, bb: 75)
  t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 25, bb: 75)
  #t.addRow(pa: 600, h: 110, b2: 30, b3: 2, hr: 50, bb: 110)

  t

window.makeWidgetTable = ->
  t = app.Table.create()
  t.setFormula 'margin_perc',"=(dept == 'Toys') ? 0.5 : 0.2"
  t.setFormula 'm2', "=if dept == 'Toys' then 0.5 else 0.2"
  t.setFormula 'margin','=margin_perc*price'

  t.addRow(name: 'Elmo', dept: 'Toys', price: 20)
  t.addRow(name: 'Nintendo', dept: 'Toys', price: 200)
  t.addRow(name: 'Lawnmower', dept: 'Lawn', price: 500)

  t

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

app.ColumnHeaderView = Ember.View.extend
  templateName: "views_column_header"

  formulaBinding: 'column.formula'
  fieldBinding: 'column.field'

  click: (e) ->
    @set('editing',true)
    setTimeout -> 
      @.$('input').focus()
    ,100
    
  focusOut: (e) -> 
    @set('editing',false)

$ ->  
  app.set 'table', makeFreshTable()
  unless testMode
    v = app.MainView.create()
    v.append()
