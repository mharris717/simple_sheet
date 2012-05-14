jQuery.ajaxSetup({async:true});
getRemoteJsonInner = (url,f,retryOnError=true) ->
  #smeDebug("starting #{url}")
  res = null

  $.ajax
    url: url
    dataType: 'json'
    type: 'GET'
    success: (data) ->
      res = data
      f(data)
    error: (data) ->
      if retryOnError
        setTimeout ->
          getRemoteJsonInner(url,f,false)
        ,Math.random()*1500
      else
        f([])

  #smeDebug("ending #{url}")
  res

window.getRemoteJson = (url,f) ->
  getRemoteJsonInner url, (data) ->
    f(data)
    

window.smeDebug = (str) ->
  s = str
  console.debug(str)

Date.prototype.prettyStr = ->
  res = "#{@getMonth()+1}/#{@getDate()} "
  h = @getHours()
  m = @getMinutes()
  m = "0#{m}" if m < 10
  res += "#{h}:#{m}"
  res

String.prototype.toDate = ->
  res = @match("([0-9]{4})-([0-9]{2})-([0-9]{2})[T ]([0-9]{2}):([0-9]{2}):([0-9]{2})")
  if res
    new Date(res[1],res[2]-1,res[3],res[4],res[5],res[6])
  else
    null


window.setTimeoutMultiple = (f,times) ->
  setTimeout(f,t) for t in times

Handlebars.registerHelper 'prettyDate', (prop) ->
  value = Ember.getPath(this, prop);

  if value && value.toDate
    value = value.toDate() || value

  value = value.prettyStr() if value && value.prettyStr
  value = '' unless value

  new Handlebars.SafeString(value)

Handlebars.registerHelper 'deferView', (prop) ->
  window.MyArrayController.whenAllLoaded ->
    div = App.mainView.$("#table-div")
    App.mainView.tablesView = App.tablesView.create({tablesBinding: "App.tables"})
    App.mainView.tablesView.appendTo(div)
  ""

Handlebars.registerHelper 'mapBool', (prop,true_val,false_val) ->
  false_val = '' unless _.isString(false_val)
  val = Ember.getPath(this, prop)
  res = if val == true
    true_val
  else if val == false
    false_val
  else
    val

  new Handlebars.SafeString(res)

Handlebars.registerHelper 'makeTable', (band) ->
  val = Ember.getPath(this, "fullName")

  band = this.band
  fields = band.get('rowKeys')
  rows = band.get('rows')
  res = "<table class='main'><tr>"

  fieldMap = {batting_team_city: 'city', league_level: 'level', batting_team_abbr: 'abbr'}
  res += "<th>#{(fieldMap[f] || f).camelize()}</th>" for f in fields
  res += "</tr>"
  _.each rows, (row) ->
    res += "<tr>"
    res += "<td>#{row[f] || ' '}</td>" for f in fields
    res += "</tr>"
  res += "</table>"
  
  new Handlebars.SafeString(res)

String.prototype.myGsub = (pattern,str) ->
  res = "dfgdfgdfg"
  new_str = this
  while res != new_str
    res = new_str
    new_str = new_str.replace(pattern,str)

  new_str

_.join = (a,sep) ->
  res = ""
  i = 0
  f = (obj) -> 
    res += sep unless i == 0
    res += obj
    i += 1
  f obj for obj in a
  res

window.regTest = ->
  str = "2012-04-25T13:49:42-04:00"
  reg = "([0-9]{4})-([0-9]{2})-([0-9]{2})"
  res = str.match(reg)
  console.debug(res)
  res

window.onlyOnceFunc = (f) ->
  times = 0
  ->
    f() if times == 0
    times += 1