window.instanceEval = (obj,code_or_function) ->
  logger.debug "instanceEval #{code_or_function}"
  func = if typeof(code_or_function) == "string" 
    str = code_or_function
    -> eval(str)
  else 
    code_or_function
  if func
    func.apply(obj) 
  
parsers = {}
isCoffeeHash = {}

window.Eval = {
  buildParser: ((grammar) -> PEG.buildParser(grammar)).memoized('buildParser')

  getParser: (name) ->
    grammar = eval("#{name}Grammar()")
    @createParser(grammar)

  createParser: (grammar) ->
    res = @buildParser(grammar)
    res.myParse = (str) ->
      parsed = @parse(str)
      parsed.myGsub(".this.",".")
    res

  getFormulaParser: (ops) ->
    vars = _.sortBy(ops.vars, (v) -> v.length).reverse()
    vars = vars.map((v) -> "\"#{v}\"").join(" / ")
    grammar = evalGrammar().replace('"price" / "cost"',vars)
    @createParser(grammar)

  evalWrap: (str,obj) -> 
    logger.debug "evaling #{str}"
    if obj
      (-> eval(str)).apply(obj)
    else
      eval(str)

  parsePossibleCoffee: ((rawStr) ->
    str = null
    try
      str = CoffeeScript.compile("return #{rawStr}")
      logger.debug "is coffee #{str}"
    catch error
      logger.debug "is js #{rawStr}"
      str = rawStr
      
    str).memoized('parsePossibleCoffee')

  multiEval: (obj,str) ->
    str = @parsePossibleCoffee(str)
    instanceEval(obj,str)

  evalFormula: (obj,rawStr,fields) ->
    parser = if fields.parse then fields else @getFormulaParser(vars: fields)
    parsed = parser.myParse(rawStr)
    #logger.log "raw #{rawStr}\nparsed #{parsed}"
    
    #try
    @multiEval(obj,parsed)
    #catch error
    #  throw error
      #throw "parsed #{rawStr} into #{parsed} | #{error}"

}