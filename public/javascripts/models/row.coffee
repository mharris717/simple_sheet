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
    #@$cellsInner.find( (cell) -> cell.$field == f )
    @$cellHash[f]

  getCellValue: (f) ->
    cell = @cellForField(f)
    throw "no cell #{f} #{@$table.$name} " + @$fields.join(",") unless cell
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
      res = 'error'
    res
      
  evalInContextf: (rawStr) ->
    logger.debug "evalInContext #{rawStr}"
    str = rawStr

    for cell in _.sortBy(@$cells, (obj) -> obj.$field.length).reverse()
      f = cell.$field
      str = str.replace(f,"{{#{f}}}")

    subVars = (withBrackets) =>
      for cell in @$cells
        f = ff = cell.$field
        ff = "{{#{ff}}}" if withBrackets
        if str.match(ff)
          val = "this.getCellValue('#{f}')"
          str = str.replace(ff,val)

    subTableCall = (name) =>
      str = str.replace "$#{name}","this.rowFromTable('#{name}')"

    subVars(true)
    #subVars(false)

    subTableCall('widgets')

    res = null
    try
      res = eval(str)
    catch error
      res = "eval error for #{rawStr} -> #{str}"

    logger.log "evaled #{rawStr} -> #{str} -> #{res}"
    res

  toJson: ->
    res = {}
    res[cell.$field] = cell.$rawValue for cell in @$cells
    res

  rowFromTable: (name) ->
    if name == @$table.$name
      this
    else
      relation = @$table.$relations[0]
      if relation
        relation.getRow(this)
      else
        c = @$$table.$$workspace.getTable(name).$$rows.$$content
        c[0]

