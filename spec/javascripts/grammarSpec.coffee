makeBaseObj = (ops) ->
  ops.getCellValue = (k) -> this[k]
  ops

describe "grammar", ->
  it "smoke2", ->
    grammar = mathGrammar()
    parser = Eval.buildParser(grammar)
    res = parser.parse("2+2*7")
    expect(res).toEqual(16)

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
      str = "tax_rate * price"
      parsed = Eval.getFormulaParser(vars: ['price','tax_rate']).myParse(str)
      res = instanceEval(base,parsed)
      expect(res).toEqual(5)

    it 'formula vars with overlap', ->
      str = "tax_rate * price"
      parsed = Eval.getFormulaParser(vars: ['tax','price','tax_rate']).myParse(str)
      res = instanceEval(base,parsed)
      expect(res).toEqual(5)

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
      str = "true ? price : 17"
      parsed = Eval.getFormulaParser(vars: ['price','tax_rate']).myParse(str)
      res = instanceEval(base,parsed)
      expect(res).toEqual(50)

    it 'coffee if', ->
      str = "if true then price else 17"
      parsed = Eval.getFormulaParser(vars: ['price','tax_rate']).myParse(str)
      res = Eval.multiEval(base,parsed)
      expect(res).toEqual(50)



