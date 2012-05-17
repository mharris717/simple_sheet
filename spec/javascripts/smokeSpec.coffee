describe 'Stuff', ->
  it 'smoke', ->
    expect(window.App).toBeDefined()

  row = h = bavg = table = null
  beforeEach ->
    table = makeFreshTable()
    window.table = table
    row = table.$rows.$content[0]
    h = row.cellForField('h')
    bavg = row.cellForField('bavg')
    window.bavg = bavg
    table.setupAll()

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
      table.setFormula 'bavg','=5'
      expect(bavg.$value).toEqual(5)

    it 'should not change cell value if cell has own raw value', ->
      expect(bavg.$value).toEqual(0.314)
      bavg.set('rawValue','=14')
      table.setFormula 'bavg','=5'
      expect(bavg.$value).toEqual(14)


