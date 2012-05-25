window.instanceEval = (obj,code_or_function) ->
  func = if typeof(code_or_function) == "string" 
    str = code_or_function
    -> eval(str)
  else 
    code_or_function
  if func
    func.apply(obj) 
  
window.Eval = {
  getParser: (name) ->
    grammar = eval("#{name}Grammar()")
    @createParser(grammar)

  createParser: (grammar) ->
    res = PEG.buildParser(grammar)
    res.myParse = (str) ->
      parsed = @parse(str)
      parsed.replace(".this.",".")
    res

  getFormulaParser: (ops) ->
    vars = _.sortBy(ops.vars, (v) -> v.length).reverse()
    vars = vars.map((v) -> "\"#{v}\"").join(" / ")
    grammar = evalGrammar().replace('"price" / "cost"',vars)
    @createParser(grammar)

  evalWrap: (str,obj) -> 
    logger.log "evaling #{str}"
    if obj
      (-> eval(str)).apply(obj)
    else
      eval(str)

  parsePossibleCoffee: (str) ->
    try
      eval(str)
      str
    catch error
      str = CoffeeScript.compile("return #{str}")
      eval(str)
      logger.log "is coffee #{str}"
      str

  multiEval: (str) ->
    try
      eval(str)
    catch error
      eval(CoffeeScript.compile("return #{str}"))
}