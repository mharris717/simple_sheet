window.evalGrammar = function() { return 'start
  = stuff:(var / table / anything)+ { return stuff.join("") }

anything
  = .

var
  = v:possibleVar { return "this.getCellValue(\'" + v + "\')" }

table
  = "$" name:[a-z]+ { return "this.rowFromTable(\'" + name.join("") + "\')" }

possibleVar
  = "price" / "cost" '}