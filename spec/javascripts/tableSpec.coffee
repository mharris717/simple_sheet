describe 'Stuff', ->
  it 'smoke', ->
    expect(window.App).toBeDefined()

  describe 'widgets', ->
    row = table = lastRow = null
    
    describe "from widgets table", ->
      beforeEach ->
        getWorkspacesFresh()
        workspace = getWorkspaces()[1]
        table = workspace.$tables.$content[0]
        row = table.$rows.$content[0]
        lastRow = table.$rows.$content[2]
        table.setupAll()

      it 'smoke', ->
        expect(row.getCellValue('price')).toEqual(20)

      it 'relation', ->
        res = row.evalInContext("$depts.min_prc")
        expect(res).toEqual(50)

      it 'relation2', ->
        res = lastRow.evalInContext("$depts.min_prc")
        expect(res).toEqual(100)

    describe "from depts table", ->
      beforeEach ->
        workspace = getWorkspaces()[1]
        table = workspace.$tables.$content[1]
        row = table.$rows.$content[0]
        lastRow = table.$rows.$content[1]
        table.setupAll()
 
      it 'phantom table returns no row', ->
        expect(row.rowFromTable('sdfsdf')).toBeUndefined()

      it 'works other direction', ->
        expect(row.rowFromTable('widgets')).toBeDefined()


  describe 'sum across relation', ->
    row = players = stats = null
    beforeEach ->
      workspace = getWorkspaces()[0]
      stats = workspace.$tables.$content[0]
      players = workspace.$tables.$content[1]

      players.addColumn 'pa', '=$stats.pa'

      row = players.$rows.$content[0]

      players.setupAll()

    it 'should sum', ->
      res = row.evalInContext("$stats.hr.sum")
      expect(res).toEqual(40)

    it 'should sum 2', ->
      res = row.getCellValue('pa')
      expect(res).toEqual(1200)

    describe "bunch", ->
      for i in [0...1]
        describe 'new stats row - fully formed', ->
          beforeEach ->
            c = row.cellForField('pa')
            c.set 'rawValue'," "

            row.getCellValue('pa')
            stats.addRow(name: 'Ted Williams', year: 1957, pa: 600, hr: 10)

          it 'should sum to new value', ->
            res = row.getCellValue('pa')
            expect(res).toEqual(1800)

        describe 'new stats row - not fully formed', ->
          beforeEach ->
            c = row.cellForField('pa')
            c.set 'rawValue'," "

            row.getCellValue('pa')
            Ember.run ->
              newRow = stats.addRow(name: 'Ted Williamsx', year: 1957, pa: 600, hr: 10)
              newRow.set 'name', 'Ted Williams'

          it 'should sum to new value', ->
            res = row.getCellValue('pa')
            expect(res).toEqual(1800)



  describe 'baseball', ->
    row = h = bavg = table = null
    beforeEach ->
      workspace = getWorkspaces()[0]
      table = workspace.$tables.$content[0]
      row = table.$rows.$content[0]
      h = row.cellForField('h')
      bavg = row.cellForField('bavg')

      noRow unless row
      noHField unless h
      window.bavg = bavg
      #table.addColumn('iso',"=slg-bavg")
      table.setupAll()

    describe "basic", ->
      it 'h', ->
        expect(h.$value).toEqual 165

    if true
      describe "basic value changes", ->
        it 'h', ->
          expect(h.$value).toEqual 165

        it 'bavg', ->
          expect(bavg.$value).toEqual 0.314

        it 'bavg changes when h changes', ->
          h.set('rawValue',200)
          expect(bavg.$value).toEqual(roundNumber(200.0/525.0,3))

        it "bavg changes when formula changes", ->
          bavg.set('rawValue',"=h/ab*2")
          expect(bavg.$value).toEqual(0.629)

        it 'long', ->
          for i in [0...10]
            #Ember.run ->
            h.set 'rawValue', i

      describe "column formula", ->
        it 'should change cell value', ->
          expect(bavg.$value).toEqual(0.314)
          Ember.run.begin()
          table.setFormula 'bavg','=5'
          Ember.run.end()
          expect(bavg.$value).toEqual(5)

        it 'should not change cell value if cell has own raw value', ->
          expect(bavg.$value).toEqual(0.314)
          bavg.set('rawValue','=14')
          table.setFormula 'bavg','=5'
          expect(bavg.$value).toEqual(14)

        it 'can set column formula as a constant', ->
          table.setFormula 'bavg',9
          expect(bavg.$value).toEqual(9)

      describe "new column", ->
        it 'something', ->
          table = makeFreshTable()
          table.addColumn('iso',"=slg-bavg")
          row = table.$rows.$content[0]
          expect(row.getCellValue('iso')).toEqual(0.151)


    describe "row from another table", ->
      it 'smoke', ->
        expect(row.rowFromTable('players')).toBeDefined()

      it 'formula', ->
        formula = "if $players.side == 'L' then 10 else 20"
        res = row.evalInContext(formula)
        expect(res).toEqual(10)

      describe "multiple related rows", ->




