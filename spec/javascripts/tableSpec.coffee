describe 'Stuff', ->
  it 'smoke', ->
    expect(window.App).toBeDefined()

  describe 'real stuff', ->
    row = h = bavg = table = null
    beforeEach ->
      workspace = getWorkspace()
      table = workspace.$tables.$content[0]
      window.table = table
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
          table.addColumn('iso',"=slg-bavg")
          table = makeFreshTable()
          window.table = table
          row = table.$rows.$content[0]
          Ember.run ->
            #expect(row.cellForField('iso').$value).toEqual(0.151)


    describe "row from another table", ->
      it 'smoke', ->
        expect(row.rowFromTable('widgets')).toBeDefined()
      it 'formula', ->
        formula = "=$widgets"

