window.roundNumber = (num, dec) ->
  Math.round(num*Math.pow(10,dec))/Math.pow(10,dec)

app.Cell = Ember.Object.extend
  tableBinding: "row.table"
  init: ->
    logger.debug "making a cell " + @$field

  recalc: ->
    #logger.log 'recalc'
    @notifyPropertyChange('rawValue')

  recalcSpecial: ->
    #logger.log "recalc special"
    @notifyPropertyChange('rawValue')

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
  
  primitiveValue: (->
    res = @$rawValueOrFormula
    row = @$row 

    res = if Eval.isFormula(res)
      res = row.evalInContext(res)
      res = roundNumber(res,3) if _.isNumber(res)
      res
    else
      res      

    res).property('rawValue','row.table.workspace.relations.@each.formula').cacheable()

  value: (-> 
    res = @$primitiveValue
    if res && res.toValue
      res.toValue()
    else
      res ).property('primitiveValue')

  areObserversSetup: false
  ensureSetupObservers: ->
    if !@areObserversSetup
      @setupObservers()
      @areObserversSetup = true
      
  setupObservers: ->
    d = app.CellDeps.create(cell: this, value: @$rawValueOrFormula)
    d.setupObservers()

  triggerSave: ->
    @$table.save()

  rawValueChanged: (->
   @setupObservers()
   @triggerSave() unless testMode
  ).observes('rawValue')



app.Cell.CompositeCell = Em.Object.extend
  toValue: (type='sum') ->
    @$values[type]()

  values: (->
    @$cells.map (obj) -> obj.$value).property('cells.@each.value')











  