window.evalGrammar = function() { return 'start\n\
  = stuff:(varWithAgg / var / table / anything)+ { return (stuff.join ? stuff.join("") : "FOOBAR") }\n\
\n\
anything\n\
  = .\n\
\n\
var\n\
  = v:cleanVar { return "this.getCellValue(\'" + v + "\')" }\n\
\n\
table\n\
  = "$" name:[a-z]+ { return "this.rowFromTable(\'" + (name.join ? name.join("") : "OTHER FOOBAR") + "\')" }\n\
\n\
varChar\n\
  = [a-z_]\n\
\n\
varWithAgg\n\
  = v:cleanVar "." mm:minMax { return "this.getCellValue(\'" + v + "\',\'"+mm+"\')" }\n\
\n\
cleanVar\n\
  = pv:possibleVar !varChar { return pv }\n\
\n\
minMax\n\
  = "min" / "max"\n\
\n\
possibleVar\n\
  = "price" / "cost" '}