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
    @set 'relations', App.Relations.create(table: this)
    #@setupAll()

  relationCount: (-> @$relations.$content.length).property("relations.@each")

  save: -> 4

  saveName: -> @$name

  setFormula: (k,v) ->
    @$formulas.setFormula(k,v)
    
  fieldsFromRows: (->
    res = {}
    for row in @$rows.$content
      for own k,v of row
        if k != '_super' && k != 'table' && !k.match(/binding$/i)
          res[k] = true 
    _.keys(res)).property('rows.@each').cacheable()

  fields: (->
    res = @$fieldsFromRows
    res = res.concat(@$addlFields.$content)
    _.uniq(res)).property('fieldsFromRows','addlFields.@each')

  fieldsForParser: ->
    res = @$fields
    for table in @$relations.relatedTables()
      res = res.concat(table.$fieldsFromRows)
    _.uniq(res)

  columns: (->
    app.Column.create(table: this, field: f) for f in @$fields).property('fields')
  
  addRow: (h) ->
    h[k] ||= null for k in @$formulas.fields()
    row = app.Row.create(h)
    row.set('table',this)
    @$rows.pushObject(row)
    row

  setupAll: ->
    logger.log "setupAll"
    for row in @$rows.$content
      for cell in row.$cells
        cell.setupObservers()
        cell.recalc()

  addColumn: (col,form) ->
    @$addlFields.pushObject(col)
    @setFormula(col,form) if isPresent(form)

  addRelation: (otherTable, formula) -> 
    @$relations.add otherTable, formula

  formulaParser: ->
    @cachedParser ||= Eval.getFormulaParser(vars: @fieldsForParser())

  countCell: (->
    @$rows.$content.length).property('rows.@each')

  toJson: ->
    res = {}
    res.formulas = @$formulas.$fieldHash
    res.addlFields = @$addlFields.toJson()
    res.rows = @$rows.toJson()
    res.relations = @$relations.toJson()
    res.name = @$name
    res

  hydrate: (raw) ->
    @set 'name', raw.name
    @setFormula(k,v) for k,v of raw.formulas
    @addColumn(f) for f in raw.addlFields
    @addRow(row) for row in raw.rows
    @addRelation row.otherTableName, row.formula for row in raw.relations


  loadCSV: (csv) ->
    return
    #csv = escape(csv)
    $.post "/convert", {body: csv}, (rows) =>
      console.debug "csv #{rows.length} for #{@$name}"
      @addRow(row) for row in rows
      console.debug 'saving csv'
      SimpleSave.save(this)
    ,'json'


app.TableView = Em.View.extend
  templateName: "views_table"
  workspaceBinding: "table.workspace"

  delete: (e) ->
    @$workspace.removeTable(@$table)

  showSettings: (e) ->
    this.$('.settings').show()

  showCSV: (e) ->
    this.$('.load-csv').show()

  loadCSV: (e) ->
    @$table.loadCSV @$csvContent
    this.$('.load-csv').hide()
    this.$('.settings').hide()


app.Table.load = ->
  raw = $.jStorage.get('table')
  res = null
  if raw && raw.rows.length && raw.rows.length > 0
    res = app.Table.create()
    res.hydrate(raw)
  else
    res = makeFreshTable()

  res

    