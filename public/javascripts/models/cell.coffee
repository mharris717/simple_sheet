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
    @$row.$table.$fields.filter (f) => 
      @rawValueOrFormula() && 
      @rawValueOrFormula().match && 
      @rawValueOrFormula().match(f) 

  depCells: ->
    deps = @deps()
    res = @$row.$cellsInner.filter (cell) => _.include(deps,cell.$field)
    #logger.log "depCells for #{@$field} #{res.length} #{@$row.$cells.length} #{@deps().length}"
    res
    

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

  rawValueOrFormula: ->
    res = @$rawValue 
    res = @$row.$table.$formulas.get(@$field) if isBlank(res)
    res

  columnFormula: (->
    @$row.$table.$formulas.get(@$field)).property("row.table.formulas")
  
  value: (->
    logger.debug "value call for #{@$field}"
    res = @rawValueOrFormula()
    row = @$row 

    if res && res.substr && res.substr(0,1) == '='
      rest = res.substr(1,999)
      res = row.evalInContext(rest)
      res = roundNumber(res,3) if _.isNumber(res)
      res
    else
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