window.makeFreshTable = ->      
  t = app.Table.create(name: 'stats')
  t.setFormula(k,v) for k,v of {bavg: "=h/ab", ab: "=pa-bb", tb: "=h+b2+b3*2+hr*3", obp: "=(bb+h)/pa", slg: "=tb/ab", ops: "=obp+slg"}

  t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 15, bb: 75)
  t.addRow(pa: 600, h: 165, b2: 30, b3: 2, hr: 25, bb: 75)
  #t.addRow(pa: 600, h: 110, b2: 30, b3: 2, hr: 50, bb: 110)

  t

window.makeWidgetTable = ->
  t = app.Table.create(name: 'widgets')
  t.setFormula 'mperc',"=(dept == 'Toys') ? 0.5 : 0.2"
  t.setFormula 'm2', "=if dept == 'Toys' then 0.5 else 0.2"
  t.setFormula 'margin','=mperc*price'

  t.addRow(name: 'Elmo', dept: 'Toys', price: 20)
  t.addRow(name: 'Nintendo', dept: 'Toys', price: 200)
  t.addRow(name: 'Lawnmower', dept: 'Lawn', price: 500)

  t