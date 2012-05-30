(function() {
  var app, isCoffeeHash, parsers;
  app = window.App;
  window.instanceEval = function(obj, code_or_function) {
    var func, str;
    logger.debug("instanceEval " + code_or_function);
    func = typeof code_or_function === "string" ? (str = code_or_function, function() {
      return eval(str);
    }) : code_or_function;
    if (func) {
      return func.apply(obj);
    }
  };
  parsers = {};
  isCoffeeHash = {};
  window.Eval = {
    buildParser: (function(grammar) {
      return PEG.buildParser(grammar);
    }).memoized('buildParser'),
    getParser: function(name) {
      var grammar;
      grammar = eval("" + name + "Grammar()");
      return this.createParser(grammar);
    },
    createParser: function(grammar) {
      var res;
      res = this.buildParser(grammar);
      res.myParse = function(str) {
        var parsed;
        parsed = this.parse(str);
        return parsed.myGsub(".this.", ".");
      };
      return res;
    },
    getFormulaParser: function(ops) {
      var grammar, vars;
      vars = _.sortBy(ops.vars, function(v) {
        return v.length;
      }).reverse();
      vars = vars.map(function(v) {
        return "\"" + v + "\"";
      }).join(" / ");
      grammar = evalGrammar().replace('"price" / "cost"', vars);
      return this.createParser(grammar);
    },
    evalWrap: function(str, obj) {
      logger.debug("evaling " + str);
      if (obj) {
        return (function() {
          return eval(str);
        }).apply(obj);
      } else {
        return eval(str);
      }
    },
    parsePossibleCoffee: (function(rawStr) {
      var str;
      str = null;
      try {
        str = CoffeeScript.compile("return " + rawStr);
        logger.debug("is coffee " + str);
      } catch (error) {
        logger.debug("is js " + rawStr);
        str = rawStr;
      }
      return str;
    }).memoized('parsePossibleCoffee'),
    multiEval: function(obj, str) {
      str = this.parsePossibleCoffee(str);
      return instanceEval(obj, str);
    },
    evalFormula: function(obj, rawStr, fields) {
      var parsed, parser;
      parser = fields.parse ? fields : this.getFormulaParser({
        vars: fields
      });
      parsed = parser.myParse(rawStr);
      return this.multiEval(obj, parsed);
    }
  };
}).call(this);
