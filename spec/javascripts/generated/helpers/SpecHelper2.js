(function() {
  beforeEach(function() {
    return this.addMatchers({
      toEvalTo: function(exp, ops) {
        var act, form, parsed, parser;
        form = this.actual;
        parser = ops.parser ? ops.parser : ops.vars ? Eval.getFormulaParser({
          vars: ops.vars
        }) : void 0;
        parsed = parser ? parser.myParse(form) : form;
        act = null;
        try {
          act = Eval.multiEval(ops.base, parsed);
        } catch (error) {
          act = error;
        }
        this.message = function() {
          return "Expected '" + act + "' to be '" + exp + "', form " + form + ", parsed to " + parsed;
        };
        return act === exp;
      }
    });
  });
}).call(this);
