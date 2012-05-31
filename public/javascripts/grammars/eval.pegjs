window.evalGrammar = function() { return 'start
  = stuff:(varWithAgg / var / table / anything)+ { return (stuff.join ? stuff.join("") : "FOOBAR") }

anything
  = .

var
  = v:cleanVar { return "this.getCellValue(\'" + v + "\')" }

table
  = "$" name:[a-z]+ { return "this.rowFromTable(\'" + (name.join ? name.join("") : "OTHER FOOBAR") + "\')" }

varChar
  = [a-z_]

varWithAgg
  = v:cleanVar "." mm:minMax { return "this.getCellValue(\'" + v + "\',\'"+mm+"\')" }

cleanVar
  = pv:possibleVar !varChar { return pv }

minMax
  = "min" / "max" / "avg"

possibleVar
  = "price" / "cost" '}