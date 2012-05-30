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
  
  value: (->
    res = @$rawValueOrFormula
    row = @$row 

    res = if res && res.substr && res.substr(0,1) == '='
      rest = res.substr(1,999)
      logger.debug "eval #{@$field} | #{rest}"
      res = row.evalInContext(rest)
      res = roundNumber(res,3) if _.isNumber(res)
      res
    else
      res
    #logger.log "value call for #{@$field} res #{res}"
    res).property('rawValue').cacheable()

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

