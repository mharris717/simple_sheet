app = window.App

window.roundNumber = (num, dec) ->
  Math.round(num*Math.pow(10,dec))/Math.pow(10,dec)


app.Cell = Ember.Object.extend
  init: ->
    logger.log "making a cell " + @$field
    setTimeout =>
      @rawValueChanged()
    ,1000
    
  recalc: ->
    logger.log 'recalc'
    v = @$rawValue
    @set('rawValue',""+v+" ")

  deps: ->
    @$row.$fields.filter (f) => 
      @$rawValue && 
      @$rawValue.match && 
      @$rawValue.match(f) 

  depCells: ->
    deps = @deps()
    @$row.$cells.filter (cell) => _.include(deps,cell.$field)
    
  res = Ember.computed (k,v) ->
    logger.debug "rawValue call"
    f = @$field
    row = @$row
    if arguments.length == 1
      logger.debug "getting rawValue"
      row.get(f) || row.$table.$formulas[f]
    else
      logger.debug "setting rawValue"
      row.set(f,v)
      v
  rawValue: res.property().cacheable()
  
  value: (->
    logger.debug "value call"
    res = @$rawValue
    row = @$row

    if res && res.substr && res.substr(0,1) == '='
      rest = res.substr(1,999)
      res = row.evalInContext(rest)
      res = roundNumber(res,3) if _.isNumber(res)
      res
    else
      res).property('rawValue').cacheable()
      
  valueChanged: (-> 
    logger.log('observe')
    for cell in @$row.$cells
      deps = cell.deps()
      if _.include(deps,@$field)
        logger.log "need to update #{cell.$field}"
        cell.recalc()

  )#.observes('value')

  rawValueChanged: (->
    me = this
    logger.log 'rawValueChanged'
    for cell in @depCells()
      logger.log "adding observer from #{@$field} to #{cell.$field}"
      cell.addObserver 'value',me,@recalc
  ).observes('rawValue')

logger.log "finished with cell"