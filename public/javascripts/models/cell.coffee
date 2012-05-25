window.roundNumber = (num, dec) ->
  Math.round(num*Math.pow(10,dec))/Math.pow(10,dec)

app.Cell = Ember.Object.extend
  tableBinding: "row.table"
  init: ->
    logger.debug "making a cell " + @$field
    #setTimeout =>
    #@rawValueChanged()
    #,1001
    
  recalc: ->
    logger.debug "recalc for #{@$field}"
    v = @$rawValue
    if isPresent(v)
      v = if v == v.trim() then ""+v+" " else v.trim()
      @set('rawValue',v)
    else if !v
      @set('rawValue'," ")
    else
      @set('rawValue',""+v+" ")


  deps: ->
    v = @$rawValueOrFormula
    if v && v.match
      @$row.$table.$fields.filter (f) => v.match(f)
    else
      []

  foreignDeps: ->
    logger.debug "foreignDeps call"
    if false
      []
    else
      v = @$rawValueOrFormula
      if v && v.match
        res = v.scan(/\$[a-z_]+\.[a-z_]+/)
        logger.debug res
        res || []
      else
        []

  depCells: ->
    deps = @deps()
    res = @$row.$cellsInner.filter (cell) => _.include(deps,cell.$field)

    foreign = []
    for full in @foreignDeps()
      logger.debug "doing foreign"
      arr = full.substr(1,999).split(".")
      table = arr[0]
      field = arr[1]
      foreign.push @$row.rowFromTable(table).cellForField(field)

    #logger.log "depCells for #{@$field} #{res.length} #{@$row.$cells.length} #{@deps().length}"
    res.concat(foreign)
    

  res = (Ember.computed (k,v) ->
    f = @$field
    row = @$row
    if arguments.length == 1
      logger.debug "getting rawValue"
      row.get(f)
    else
      logger.debug "setting rawValue to #{v}"
      row.set(f,v)
      v)
  rawValue: res.property().cacheable()

  rawValueOrFormula: (->
    res = @$rawValue 
    res = @$columnFormula if isBlank(res)
    res).property('rawValue','columnFormula')

  columnFormula: (->
    @$row.$table.$formulas.get(@$field)).property("row.table.formulas")
  
  value: (->
    res = @$rawValueOrFormula
    row = @$row 

    res = if res && res.substr && res.substr(0,1) == '='
      rest = res.substr(1,999)
      logger.log "eval #{@$field} | #{rest}"
      res = row.evalInContext(rest)
      res = roundNumber(res,3) if _.isNumber(res)
      res
    else
      res
    logger.log "value call for #{@$field} res #{res}"
    res).property('rawValue').cacheable()

  areObserversSetup: false
  ensureSetupObservers: ->
    if !@areObserversSetup
      @setupObservers()
      @areObserversSetup = true
      
  setupObservers: ->
    me = this
    for cell in @depCells()
      logger.debug "adding observer from #{@$field} to #{cell.$field}"
      cell.removeObserver 'value',me,@recalc
      cell.addObserver 'value',me,@recalc
    @$row.$table.$formulas.removeObserver @$field, me, @recalc
    @$row.$table.$formulas.addObserver @$field, me, @recalc

  triggerSave: ->
    @$table.save()

  rawValueChanged: (->
   @setupObservers()
   @triggerSave() unless testMode
  ).observes('rawValue')

app.Column = Ember.Object.extend
  formula: ((k,v) ->
    if arguments.length == 1
      @$table.$formulas.get(@$field)
    else
      @$table.setFormula(@$field,v)
      v).property('table.formulas')