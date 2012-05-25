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