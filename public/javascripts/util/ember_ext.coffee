Em.Object.prototype.safeGet = (k) ->
  res = @get(k)
  throw "get for #{k} returned null for #{this}" unless res
  res

Em.ArrayController.reopen
  toJson: ->
    _.map @$content, (obj) -> if obj.toJson then obj.toJson() else obj

baseObjProps = ->
  res = {}
  res[k] = true for k,v of Em.Object.create()
  res

Em.Object.reopen
  myProperties: ->
    base  = baseObjProps()
    isGood = (k,v) ->
      return false if base[k]
      return false if _.isFunction(v)
      return false if v == undefined
      return false if k == 'row' || k == 'table' || k == 'baseTable' || k == 'workspace' || k == 'toJson'
      true
    res = []
    for k,v of this
      res.push(k) if isGood(k,v)
    res

  toJson: (ops) ->
    #console.debug 'json call'
    res = {}
    for prop in @myProperties()
      window.propCalls ||= {}
      window.propCalls[prop] ||= 0
      window.propCalls[prop] += 1
      val = @get(prop)
      val = val.toJson() if val.toJson
      res[prop] = val
    res