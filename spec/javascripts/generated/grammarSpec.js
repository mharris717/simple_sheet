(function() {
  var makeBaseObj;
  makeBaseObj = function(ops) {
    ops.getCellValue = function(k) {
      return this[k];
    };
    return ops;
  };
  describe("grammar", function() {
    it("smoke2", function() {
      var grammar, parser, res;
      grammar = mathGrammar();
      parser = Eval.buildParser(grammar);
      res = parser.parse("2+2*7");
      return expect(res).toEqual(16);
    });
    describe('min/max', function() {
      var parser;
      parser = null;
      beforeEach(function() {
        return parser = Eval.getFormulaParser({
          vars: ['tax', 'price', 'tax_rate', 'target']
        });
      });
      it('sum', function() {
        var res;
        res = [1, 2, 3].sum();
        return expect(res).toEqual(6);
      });
      return it('parses min max', function() {
        var parsed, str;
        str = "$widgets.price.max";
        parsed = parser.myParse(str);
        return expect(parsed).toEqual("this.rowFromTable('widgets').getCellValue('price','max')");
      });
    });
    describe('eval', function() {
      var base;
      base = null;
      beforeEach(function() {
        return base = makeBaseObj({
          price: 50,
          cost: 30,
          tax_rate: 0.1
        });
      });
      it('smoke', function() {
        var parsed, res, str;
        str = "price + 4";
        parsed = Eval.getParser('eval').parse(str);
        expect(parsed).toEqual("this.getCellValue('price') + 4");
        res = instanceEval(base, parsed);
        return expect(res).toEqual(54);
      });
      it('formula vars', function() {
        return expect("tax_rate * price").toEvalTo(5, {
          base: base,
          vars: ['tax_rate', 'price']
        });
      });
      it('formula vars with overlap', function() {
        return expect("tax_rate * price").toEvalTo(5, {
          base: base,
          vars: ['tax', 'price', 'tax_rate']
        });
      });
      return describe('table vars', function() {
        beforeEach(function() {
          return base.rowFromTable = function(t) {
            if (t === 'depts') {
              return makeBaseObj({
                target: 500
              });
            } else {
              throw "unknown table";
            }
          };
        });
        return it('smoke', function() {
          var parsed, res, str;
          str = "$depts.target * price";
          parsed = Eval.getFormulaParser({
            vars: ['tax', 'price', 'tax_rate', 'target']
          }).myParse(str);
          res = instanceEval(base, parsed);
          return expect(res).toEqual(500 * 50);
        });
      });
    });
    describe("instance eval", function() {
      it('string', function() {
        var base, res;
        base = {
          a: 14
        };
        res = instanceEval(base, "this.a+3");
        return expect(res).toEqual(17);
      });
      return it('func', function() {
        var base, f, res;
        base = {
          a: 14
        };
        f = function() {
          return this.a + 3;
        };
        res = instanceEval(base, f);
        return expect(res).toEqual(17);
      });
    });
    describe("basic js", function() {
      var base;
      base = null;
      beforeEach(function() {
        return base = makeBaseObj({
          price: 50,
          cost: 30,
          tax_rate: 0.1
        });
      });
      it('tertiary if', function() {
        return expect("true ? price : 17").toEvalTo(50, {
          base: base,
          vars: ['price', 'tax_rate']
        });
      });
      return it('coffee if', function() {
        return expect("if true then price else 17").toEvalTo(50, {
          base: base,
          vars: ['price', 'tax_rate']
        });
      });
    });
    return describe("proper variable parsing", function() {
      var base;
      base = null;
      beforeEach(function() {
        return base = makeBaseObj({
          ab: 100,
          h: 25
        });
      });
      it('can eval bavg', function() {
        return expect("h/ab").toEvalTo(0.25, {
          base: base,
          vars: ['h', 'ab']
        });
      });
      it('can eval formula with h in it', function() {
        return expect("if true then 2 else 3").toEvalTo(2, {
          base: base,
          vars: ['h', 'ab']
        });
      });
      it('can eval formula with h in it 2', function() {
        return expect("if true then 'hit' else 'miss'").toEvalTo('hit', {
          base: base,
          vars: ['h', 'ab']
        });
      });
      return it('can eval formula with h in it 2', function() {
        return expect("if true then 'h_z' else 'miss'").toEvalTo('h_z', {
          base: base,
          vars: ['h', 'ab']
        });
      });
    });
  });
}).call(this);
