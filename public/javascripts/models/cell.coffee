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
    res = res.toValue() if res && res.toValue
    res).property('rawValue','row.table.workspace.relations.@each.formula').cacheable()

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

Array.prototype.max = ->
  res = this[0]
  return res if @length == 0
  return this[0] if @length == 1
  for obj in this
    obj = parseFloat(obj) if obj
    if !res
      res = obj
    else if obj && obj > res
      res = obj
  res

Array.prototype.min = ->
  res = this[0]
  return res if @length == 0
  return this[0] if @length == 1
  for obj in this
    obj = parseFloat(obj) if obj
    if !res
      res = obj
    else if obj && obj < res
      res = obj
  res

Array.prototype.avg = ->
  return 0 if @length == 0
  res = 0
  for obj in this
    if obj
      res += parseFloat(obj)
  res / @length

Array.prototype.sum = ->
  return 0 if @length == 0
  res = 0
  for obj in this
    if obj
      res += parseFloat(obj)
  res

app.Cell.CompositeCell = Em.Object.extend
  toValue: (type='sum') ->
    @$values[type]()

  values: (->
    @$cells.map (obj) -> obj.$value).property('cells.@each.value')











  