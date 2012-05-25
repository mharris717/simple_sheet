window.makeFreshTable = ->      
  t = app.Table.create(name: 'stats')
  t.setFormula(k,v) for k,v of {bavg: "=h/ab", ab: "=pa-bb", tb: "=h+b2+b3*2+hr*3", obp: "=(bb+h)/pa", slg: "=tb/ab", ops: "=obp+slg"}

  t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 15, bb: 75)
  t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 25, bb: 75)
  #t.addRow(pa: 600, h: 110, b2: 30, b3: 2, hr: 50, bb: 110)

  t

window.makeWidgetTable = ->
  t = app.Table.create(name: 'widgets')
  t.setFormula 'mperc',"=if dept == 'Toys' then 0.5 else 0.2"
  #t.setFormula 'm2', "=if dept == 'Toys' then 0.5 else 0.2"
  t.setFormula 'margin','=mperc*price'
  t.setFormula 'above_min', "=if $widgets.price > $depts.min_prc then 'Yes' else 'No '+$widgets.price+' '+$depts.min_prc"

  t.addRow(name: 'Elmo', dept: 'Toys', price: 20)
  t.addRow(name: 'Nintendo', dept: 'Toys', price: 200)
  t.addRow(name: 'Lawnmower', dept: 'Lawn', price: 500)



  t.addRelation "depts", "$widgets.dept == $depts.name"

  t

window.makeDeptTable = ->
  t = app.Table.create(name: 'depts')
  t.addRow(name: 'Toys', min_prc: 50)
  t.addRow(name: 'Lawn', min_prc: 100)
  t