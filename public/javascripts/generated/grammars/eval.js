window.evalGrammar = function() { return 'start\n\
  = stuff:(var / table / anything)+ { return (stuff.join ? stuff.join("") : "FOOBAR") }\n\
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
cleanVar\n\
  = pv:possibleVar !varChar { return pv }\n\
\n\
possibleVar\n\
  = "price" / "cost" '}