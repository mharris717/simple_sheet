Em.Object.prototype.safeGet = (k) ->
  res = @get(k)
  throw "get for #{k} returned null for #{this}" unless res
  res