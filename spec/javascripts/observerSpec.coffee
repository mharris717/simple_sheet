checkMethPresence = (cls, meth) ->
  res = {}
  strs = []
  objs = {klass: cls, obj: cls.create(), pro: cls.prototype, objPro: cls.create().prototype}
  for type, obj of objs
    if obj
      console.debug type
      console.debug obj
      f = obj[meth]
      res["#{type} basic"] = f
      res["#{type} invoked"] = if (f && f.call) then f.call() else undefined
      res["#{type} get"] = if obj.get then obj.get(meth) else undefined
      res["#{type} keys"] = _.keys(obj).sort()

  for type,val of res
    str = "#{type}: #{val}"
    strs.push(str)
    console.debug(str)

  strs.join("\n")

VolitileObserve = Ember.Mixin.create
  setupVolitileObservers:  ->
    info = @volitileSetupInfo()
    for target in info.targets
      target.obj.addObserver target.property, this, target.callback
    for prop in info.watch
      @addObserver prop,this,@setupVolitileObservers

window.Person = Em.Object.extend VolitileObserve, 
  init: ->
    @set('name','Adam') unless @$name

  doubleName: (-> "#{@$name}#{@$name}" ).property('name')


describe 'observer testing', ->
  list = adam = brian = chris = null
  setupList = ->
    list = Em.ArrayController.create(content: [])
    list.pushObject(Person.create(name: 'Adam'))
    list.pushObject(Person.create(name: 'Brian'))
    list.pushObject(Person.create(name: 'Chris'))
    adam = list.$content[0]
    brian = list.$content[1]
    chris = list.$content[2]

  beforeEach ->
    setupList()
    

  it "should observe - simple", ->
    val = 0
    f = -> val += 1
    adam.addObserver 'name',this,f
    adam.set 'name', 'Steve'
    expect(val).toEqual(1)

  it "should observe - all", ->
    val = 0
    f = -> val += 1
    list.addObserver '@each.name',this,f
    adam.set 'name', 'Steve'
    expect(val).toEqual(1)

  it "should observe - all2", ->
    val = 0
    f = -> val += 1
    list.addObserver '@each.name',this,f
    adam.set 'name', 'Steve'
    list.pushObject(Em.Object.create(name: 'Chris'))
    expect(val).toEqual(2)

  it 'prop stuff', ->
    res = checkMethPresence Person, 'doubleName'
    #expect(res).toEqual(14)

  describe 'volitile', ->
    callCount = null
    beforeEach ->
      callCount = 0
      cb = -> callCount += 1

      Person.reopen
        volitileSetupInfo: ->
          res = {targets: [], watch: ['name']}
          if @$name.match(/^B/)
            res.targets = [{obj: adam, property: 'name', callback: cb}]
          res

      setupList()

      obj.setupVolitileObservers() for obj in list.$content

    it 'changing adam calls cb', ->
      adam.set 'name','Dave'
      expect(callCount).toEqual(1)

    it 'changing brian does nothing', ->
      brian.set 'name','Paul'
      expect(callCount).toEqual(0)

    it 'changing chris to bob causes observers to be active', ->
      chris.set 'name', 'Bob'
      adam.set 'name','Dave'
      expect(callCount).toEqual(2)

    it 'changing brian to bob leaves only 1 observer', ->
      brian.set 'name', 'Bob'
      adam.set 'name','Dave'
      expect(callCount).toEqual(1)