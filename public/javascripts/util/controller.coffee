withCachedAndLive = (ops) ->
  doCache = $ && $.jStorage && ops.cacheName

  if doCache
    res = $.jStorage.get(ops.cacheName)
    if res
      console.debug "with cache #{ops.cacheName}"
      ops.callback(res) 

  ops.getLive (data) ->
    setTimeout ->
      console.debug "setting cache #{ops.cacheName}"
      $.jStorage.set(ops.cacheName,data) if doCache
      console.debug "set cache #{ops.cacheName}"
    ,5000
    console.debug "with live #{ops.cacheName}"
    ops.callback(data)

window.MyArrayController = MyArrayController = Ember.ArrayController.extend
  content: []
  whenLoadedFuncs: []

  loadFromJson: (ff) ->
    @withAll (all) => 
      @set('content',[])

      for obj in all
        obj.afterCreate() if obj.afterCreate
        @pushObject obj

      @loaded = true
      @afterLoaded()
      if ff
        console.debug('ff')
        ff() 

  whenLoaded: (cb) ->
    @whenLoadedFuncs.push(cb)
    cb() if @loaded

  afterLoaded: ->
    f() for f in @whenLoadedFuncs
    MyArrayController.allLoadedCheck()

  fixHashDates = (h) ->
    for k,v of h
      if v && v[0] == 'Time'
        h[k] = new Date(v[1],v[2]-1,v[3],v[4],v[5],v[6])
    h

  rawToObjs: (raw) ->
    raw = _.map(raw, fixHashDates)
    objs = _.map(raw, (obj) => @modelClass.create(obj))
    objs = _.sortBy(objs, (obj) -> obj.sortName())
    objs = objs.reverse() if @modelClass.sortReverse
    objs

  withAll: (f) ->
    withCachedAndLive
      cacheName: @get('controllerName')
      getLive: @getRawJson
      callback: (raw) =>
        @all = @rawToObjs(raw)
        f(@all)

h = {
  controllers: []
  whenLoadedFuncs: []

  myCreate: (h) ->
    res = @create(h)
    res.set('content',[])
    setTimeout -> 
      res.loadFromJson()
    ,100+Math.random()*100

    @controllers.push(res)
    res

  areAllLoaded: ->
    _.all(@controllers, (c) -> c.loaded)

  whenAllLoaded: (f) ->
    @whenLoadedFuncs.push(f)
    f() if @areAllLoaded()

  allLoadedCheck: () ->
    if @areAllLoaded()
      f() for f in @whenLoadedFuncs
}

MyArrayController[k] = v for k,v of h
