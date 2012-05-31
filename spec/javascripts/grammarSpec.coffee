makeBaseObj = (ops) ->
  ops.getCellValue = (k) -> this[k]
  ops

describe "grammar", ->
  it "smoke2", ->
    grammar = mathGrammar()
    parser = Eval.buildParser(grammar)
    res = parser.parse("2+2*7")
    expect(res).toEqual(16)

  describe 'min/max', ->
    parser = null
    beforeEach ->
      parser = Eval.getFormulaParser(vars: ['tax','price','tax_rate','target'])

    it 'sum', ->
      res = [1,2,3].sum()
      expect(res).toEqual(6)

    it 'parses min max', ->
      str = "$widgets.price.max"
      parsed = parser.myParse(str)
      expect(parsed).toEqual("this.rowFromTable('widgets').getCellValue('price','max')")

  describe 'eval', ->
    base = null
    beforeEach ->
      base = makeBaseObj(price: 50, cost: 30, tax_rate: 0.1)

    it 'smoke', ->
      str = "price + 4"

      parsed = Eval.getParser('eval').parse(str)
      expect(parsed).toEqual("this.getCellValue('price') + 4")

      res = instanceEval(base,parsed)

      expect(res).toEqual(54)

    it 'formula vars', ->
      expect("tax_rate * price").toEvalTo(5,base: base, vars: ['tax_rate','price'])

    it 'formula vars with overlap', ->
      expect("tax_rate * price").toEvalTo(5,base: base, vars: ['tax','price','tax_rate'])

    describe 'table vars', ->
      beforeEach ->
        base.rowFromTable = (t) -> 
          if t == 'depts'
            makeBaseObj(target: 500)
          else
            throw "unknown table"

      it 'smoke', ->
        str = "$depts.target * price"
        parsed = Eval.getFormulaParser(vars: ['tax','price','tax_rate','target']).myParse(str)
        res = instanceEval(base,parsed)

        expect(res).toEqual(500*50)

  describe "instance eval", ->
    it 'string', ->
      base = {a: 14}
      res = instanceEval(base,"this.a+3")
      expect(res).toEqual(17)

    it 'func', ->
      base = {a: 14}
      f = -> this.a+3
      res = instanceEval(base,f)
      expect(res).toEqual(17)

  describe "basic js", ->
    base = null
    beforeEach ->
      base = makeBaseObj(price: 50, cost: 30, tax_rate: 0.1)

    it 'tertiary if', ->
      expect("true ? price : 17").toEvalTo(50, base: base, vars: ['price','tax_rate'])

    it 'coffee if', ->
      expect("if true then price else 17").toEvalTo(50, base: base, vars: ['price','tax_rate'])

  describe "proper variable parsing", ->
    base = null
    beforeEach ->
      base = makeBaseObj(ab: 100, h: 25)

    it 'can eval bavg', ->
      expect("h/ab").toEvalTo(0.25, base: base, vars: ['h','ab'])

    it 'can eval formula with h in it', ->
      expect("if true then 2 else 3").toEvalTo(2,base: base, vars: ['h','ab'])

    it 'can eval formula with h in it 2', ->
      expect("if true then 'hit' else 'miss'").toEvalTo('hit',base: base, vars: ['h','ab'])

    it 'can eval formula with h in it 2', ->
      expect("if true then 'h_z' else 'miss'").toEvalTo('h_z',base: base, vars: ['h','ab'])


