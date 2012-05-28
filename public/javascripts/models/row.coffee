app.CompositeRow = Ember.Object.extend
  init: ->
    #@setSums()

  setSums: ->
    for field in @$rows[0].$table.$fields
      val = 0
      for row in @$rows
        val += row.getCellValue(field)
      @set field, val

  cellsForField: (f) ->
    _.map @$rows, (row) -> row.cellForField(f)

  getCellValue: (f) ->
    #@get(f)
    val = 0
    for row in @$rows
      val += row.getCellValue(f)
    val

app.Row = Ember.Object.extend
  init: ->
    logger.debug 'made a row'
    
  fieldsBinding: "table.fields"
  
  cellsInner: (->
    for k in @$table.$fields
      res = app.Cell.create(field: k, row: this)
      res).property('fields').cacheable()

  cellHash: (->
    res = {}
    res[cell.$field] = cell for cell in @$cellsInner
    res).property('cellsInner').cacheable()

  cells: (->
    cell.ensureSetupObservers() for cell in @$cellsInner
    @$cellsInner).property('cellsInner').cacheable()

  cellForField: (f) ->
    @$cellHash[f]

  getCellValue: (f) ->
    cell = @cellForField(f)
    throw "no cell #{f} in table #{@$table.$name} " + (if @$fields then @$fields.join(",") else "") unless cell
    logger.log "got #{cell.$value} for #{f}"
    res = cell.$value
    res = parseFloat(res) if res.match && res.match(/^[0-9]+$/)
    res

  multiEval: (str) ->
    try
      eval(str)
    catch error
      eval(CoffeeScript.compile("return #{str}"))


  evalInContext: (rawStr) ->
    res = null
    try
      res = Eval.evalFormula(this,rawStr,@$table.formulaParser())
    catch error
      res = 'error ' + error
    res

  toJson: ->
    res = {}
    res[cell.$field] = cell.$rawValue for cell in @$cells
    res

  rowFromTable: (name) ->
    if name == @$table.$name
      this
    else
      relation = @$table.$relations.getForTable(name)
      if relation
        rows = relation.getRows(this)
        if !rows
          throw "getRows returned garbage"
        else if rows.length > 1
          app.CompositeRow.create(rows: rows)
        else if rows.length == 1
          rows[0]
        else
          undefined
      else
        undefined
        #c = @$$table.$$workspace.getTable(name).$$rows.$$content
        #c[0]

