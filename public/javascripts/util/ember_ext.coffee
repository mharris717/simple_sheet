Em.Object.prototype.safeGet = (k) ->
  res = @get(k)
  throw k unless res
  res