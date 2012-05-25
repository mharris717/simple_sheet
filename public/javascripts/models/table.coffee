app.Formulas = Ember.Object.extend
  init: ->
    @set('fieldHash',{})

  setFormula: (k,v) ->
    @set(k,v)
    @$fieldHash[k] = v

  fields: ->
    _.keys(@$fieldHash)

app.Table = Em.Object.extend
  init: ->
    @set('rows',Ember.ArrayController.create(content: []))
    @set('formulas',app.Formulas.create())
    @set('addlFields',Ember.ArrayController.create(content: []))
    @set('saveName','abc')
    #@setupAll()

  setFormula: (k,v) ->
    @$formulas.setFormula(k,v)
    
  fieldsFromRows: (->
    res = {}
    for row in @$rows.$content
      for own k,v of row
        if k != '_super' && k != 'table'
          res[k] = true 
    _.keys(res)).property('rows.@each')

  fields: (->
    res = @$fieldsFromRows
    res = res.concat(@$addlFields.$content)
    _.uniq(res)).property('fieldsFromRows','addlFields.@each')

  columns: (->
    app.Column.create(table: this, field: f) for f in @$fields).property('fields')
  
  addRow: (h) ->
    h[k] ||= null for k in @$formulas.fields()
    row = app.Row.create(h)
    row.set('table',this)
    @$rows.pushObject(row)

  setupAll: ->
    for row in @$rows.$content
      for cell in row.$cells
        cell.setupObservers()

  addColumn: (col,form) ->
    @$addlFields.pushObject(col)
    @setFormula(col,form) if isPresent(form)

  toJson: ->
    res = {}
    res.formulas = @$formulas.$fieldHash
    res.addlFields = @$addlFields.$content
    res.rows = []
    res.rows.push(row.toJson()) for row in @$rows.$content
    res

  hydrate: (raw) ->
    @setFormula(k,v) for k,v of raw.formulas
    @addColumn(f) for f in raw.addlFields
    @addRow(row) for row in raw.rows

app.Table.load = ->
  raw = $.jStorage.get('table')
  res = null
  if raw && raw.rows.length && raw.rows.length > 0
    res = app.Table.create()
    res.hydrate(raw)
  else
    res = makeFreshTable()

  res

    