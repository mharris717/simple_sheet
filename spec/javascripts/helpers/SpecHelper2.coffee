beforeEach ->
  @addMatchers
    toEvalTo: (exp,ops) ->
      form = this.actual

      parser = if ops.parser
        ops.parser
      else if ops.vars
        Eval.getFormulaParser(vars: ops.vars)

      parsed = if parser then parser.myParse(form) else form

      act = null
      try
        act = Eval.multiEval ops.base, parsed
      catch error
        act = error

      @message = -> "Expected '#{act}' to be '#{exp}', form #{form}, parsed to #{parsed}"

      act == exp