app.CompositeRow = Ember.Object.extend
  init: ->
    #logger.log "comp row"
    #@setSums()

  table: (-> @$rows[0].$table).property('rows.@each')

  setSums: ->
    for field in @$rows[0].$table.$fields
      sum = 0
      for row in @$rows
        sum += row.getCellValue(field)
      @set field, sum

  cellsForField: (f) ->
    _.map @$rows, (row) -> row.cellForField(f)

  getCellValue: (f) ->
    #@get(f)
    sum = 0
    for row in @$rows
      v = row.getCellValue(f)
      if isPresent(v) && v != NaN
        sum += v
    sum

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
    logger.debug "got #{cell.$value} for #{f}"
    res = cell.$value
    res = parseFloat(res) if res && res.match && res.match(/^[0-9]+$/)
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
      if testMode
        throw error
      else
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

