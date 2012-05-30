window.makeFreshTable = ->      
  t = app.Table.create(name: 'stats')
  t.setFormula(k,v) for k,v of {bavg: "=h/ab", ab: "=pa-bb", tb: "=h+b2+b3*2+hr*3", obp: "=(bb+h)/pa", slg: "=tb/ab", ops: "=obp+slg"}

  t.addRow(name: 'Ted Williams', year: 1955, pa: 600, h: 165, b2: 30, b3: 2, hr: 15, bb: 75)
  t.addRow(name: 'Ted Williams', year: 1956, pa: 600, h: 165, b2: 30, b3: 2, hr: 25, bb: 75)
  t.addRow(name: 'Babe Ruth', year: 1927, pa: 600, h: 165, b2: 30, b3: 2, hr: 55, bb: 75)
  #t.addRow(pa: 600, h: 110, b2: 30, b3: 2, hr: 50, bb: 110)

  t.addRelation "players", "$players.name == $stats.name"

  t

window.makePlayersTable = ->
  t = app.Table.create(name: 'players')
  t.setFormula "hr","=$stats.hr"

  t.addRow(name: 'Ted Williams', side: 'L')
  t.addRow(name: 'Babe Ruth', side: 'R')

  t

window.makeWidgetTable = ->
  t = app.Table.create(name: 'widgets')
  #t.setFormula 'mperc',"=if dept == 'Toys' then 0.5 else 0.2"
  #t.setFormula 'm2', "=if dept == 'Toys' then 0.5 else 0.2"
  #t.setFormula 'margin','=mperc*price'
  #t.setFormula 'above_min', "=if $widgets.price > $depts.min_prc then 'Yes' else 'No '+$widgets.price+' '+$depts.min_prc"

  t.addRow(name: 'Elmo', dept: 'Toys', price: 20)
  t.addRow(name: 'Nintendo', dept: 'Toys', price: 200)
  t.addRow(name: 'Lawnmower', dept: 'Lawn', price: 500)

  t.addRelation "depts", "$widgets.dept == $depts.name"

  t

window.makeDeptTable = ->
  t = app.Table.create(name: 'depts')

  t.setFormula 'psum','=$widgets.price'

  t.addRow(name: 'Toys', min_prc: 50)
  t.addRow(name: 'Lawn', min_prc: 100)
  t

window.makeLoadTable = ->
  t = app.Table.create(name: 'loaded')

  t.loadCSV "a,b,c\n1,2,3"
  t.loadCSV "a,b,z\n4,5,6"

  t

makePresidentsTable = ->
  t = app.Table.create(name: 'presidents')

  $.get "/presidents.csv", (data) ->
    console.debug data
    t.loadCSV data
  t

window.getNamedTable = (name) ->
  map = {stats: makeFreshTable, players: makePlayersTable, widgets: makeWidgetTable, depts: makeDeptTable, load: makeLoadTable, presidents: makePresidentsTable}
  obj = SimpleSave.load(App.Table,name,allowMissing: true)
  if !obj
    obj = map[name]()
    setTimeout ->
      SimpleSave.save(obj)
    ,500

  else
    #logger.log "got named #{obj.$name}"
    #logger.log obj
  obj