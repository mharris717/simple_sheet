window.SimpleSave = {}

SimpleSave.PersistedHash = (ops) ->
  funcs = {
    get: (k) -> @getHash()[k]
    set: (k,v) ->
      @getHash()[k] = v
      @save()
    delete: (k) -> 
      delete @getHash[k]
      @save()
    save: -> $.jStorage.set @key, @getHash()
    getHash: -> 
      if @loaded
        @loadedHash
      else
        @loaded = true
        @loadedHash = $.jStorage.get(@key) || {}
    clear: ->
      @loadedHash = {}
      @loaded = true
      @save()
    size: -> @keys().length
    keys: -> _.keys(@getHash())
  }

  res = {}
  res.key = ops.key
  res[k] = v for k,v of funcs
  res

persistanceManagerPrototype = null
getPersistanceManagerPrototype = ->
  if !persistanceManagerPrototype
    pmp = persistanceManagerPrototype = {}

    pmp.save = (obj) ->
      key = @prefix + "-" + obj.saveName()
      raw = @objToJson.apply(obj)
      $.jStorage.set key, raw
      @addKey key

    pmp.load = (objName,ops) ->
      ops = {} if isBlank(ops)
      key = if ops.alreadyPrefixed then objName else @prefix + "-" + objName
      raw = $.jStorage.get(key)
      if isBlank(raw) 
        if ops.allowMissing
          return undefined
        else
          logger.log "no saved object found for #{key}" 
          throw "no saved object found for #{key}" 
      obj = @objClass.create()
      @objHydrate.apply(obj,[raw]) if isPresent(raw)
      obj

    pmp.addKey = (key) ->
      if !@keyHash.get(key)
        @keyHash.set key, true

    pmp.removeKey = (key) ->
      if @keyHash.get(key)
        @keyHash.delete key

    pmp.getKeys = -> @keyHash.keys()
    pmp.size = -> @getKeys().length

    pmp.objToJson = -> 
      @toJson()

    pmp.objHydrate = (raw) -> @hydrate(raw)

    pmp.clear = ->
      $.jStorage.deleteKey(k) for k in @keyHash.keys()
      @keyHash.clear()

    pmp.getAll = ->
      res = []
      res.push(@load(n, alreadyPrefixed: true)) for n in @getKeys()
      res

  persistanceManagerPrototype

SimpleSave.PersistanceManager = (ops) ->
  res = Object.create(getPersistanceManagerPrototype())
  #res.prototype = persistanceManagerPrototype
  res[k] = v for k,v of ops
  res.keyHash = SimpleSave.PersistedHash(key: "#{ops.prefix}-keys")
  res

SimpleSave.PersistanceManager.getManagerForObj = (obj) ->
  @managerHash ||= {}
  key = obj.__proto__.constructor
  @getManagerForClass(key)

SimpleSave.PersistanceManager.getManagerForClass = (klass) ->
  @managerHash ||= {}
  @managerHash[klass] ||= SimpleSave.PersistanceManager(prefix: ""+klass, objClass: klass)
  @managerHash[klass]

SimpleSave.PersistanceManager.save = (obj) ->
  @getManagerForObj(obj).save(obj)

SimpleSave.PersistanceManager.load = (klass,key,ops) ->
  @getManagerForClass(klass).load(key,ops)

SimpleSave.load = (a,b,c) -> SimpleSave.PersistanceManager.load(a,b,c)
SimpleSave.save = (a,b,c) -> SimpleSave.PersistanceManager.save(a,b,c)

if false
  window.SaveableObject = Ember.Object.extend
    save: ->
      raw = @toJson()
      name = "table-" + @$saveName
      $.jStorage.set(name,raw)


  window.Animal = Ember.Object.extend
    a: 1

  Animal.myExtend = (ops) ->
    res = @extend(ops)
    res.make = -> @create()
    res

  window.Cat = Animal.myExtend
    a: 2

  Animal.make = ->
    @create()