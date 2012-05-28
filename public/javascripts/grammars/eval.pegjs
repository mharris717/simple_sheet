window.evalGrammar = function() { return 'start
  = stuff:(var / table / anything)+ { return (stuff.join ? stuff.join("") : "FOOBAR") }

anything
  = .

var
  = v:cleanVar { return "this.getCellValue(\'" + v + "\')" }

table
  = "$" name:[a-z]+ { return "this.rowFromTable(\'" + (name.join ? name.join("") : "OTHER FOOBAR") + "\')" }

varChar
  = [a-z_]

cleanVar
  = pv:possibleVar !varChar { return pv }

possibleVar
  = "price" / "cost" '}