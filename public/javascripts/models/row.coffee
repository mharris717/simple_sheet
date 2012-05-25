app.Row = Ember.Object.extend
  init: ->
    logger.debug 'made a row'
    
  fieldsBinding: "table.fields"
  
  cellsInner: (->
    for k in @$table.$fields
      res = app.Cell.create(field: k, row: this)
      res).property('fields').cacheable()

  cells: (->
    cell.ensureSetupObservers() for cell in @$cellsInner
    @$cellsInner).property('cellsInner').cacheable()

  cellForField: (f) ->
    @$cells.filter( (cell) -> cell.$field == f )[0]

  getCellValue: (f) ->
    @cellForField(f).$value

  multiEval: (str) ->
    try
      eval(str)
    catch error
      eval(CoffeeScript.compile("return #{str}"))
      
  evalInContext: (rawStr) ->
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
    t = @$$table.$$workspace.getTable(name)
    r = t.$$rows
    c = r.$$content
    c[0]

