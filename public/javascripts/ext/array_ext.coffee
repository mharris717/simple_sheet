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