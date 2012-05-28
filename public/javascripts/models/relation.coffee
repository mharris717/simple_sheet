RelationOption = Em.Object.extend
  rowFromTable: (t) ->
    res = @$rows[t]

  fields: ->
    @$$relation.$$baseTable.$$workspace.$$fields

  matches: (str) ->
    res = Eval.evalFormula(this,str,@fields())
    console.debug "matches #{res} #{str}"
    console.debug @$rows
    res

app.Relation = Em.Object.extend
  # baseTable, otherTableName, formula
  otherTable: (baseRow) -> 
    ot = @$$baseTable.$$workspace.getTable(@$$otherTableName)
    res = if baseRow
      bt = baseRow.$table
      if bt != ot
        ot
      else if bt != @$baseTable
        @$baseTable
      else
        throw "something wrong"
    else
      ot

    throw "something wrong no table" unless res
    res


  getRows: (baseRow) ->
    res = []
    for otherRow in @otherTable(baseRow).$rows.$content
      if true #!res
        rows = {}
        rows[baseRow.$table.$name] = baseRow
        rows[otherRow.$table.$name] = otherRow
        console.debug baseRow.$table.$name
        console.debug rows
        option = RelationOption.create(relation: this, rows: rows)
        res.push(otherRow) if option.matches(@$formula)
    res

app.Relations = Em.ArrayController.extend
  init: ->
    @set 'content', []

  add: (otherTable, formula) ->
    ops = {baseTable: @$table, otherTableName: otherTable, formula: formula}
    r = app.Relation.create(ops)
    @pushObject r

  getForTable: (name,bothDirections=true) ->
    for rel in @content
      return rel if rel.$otherTableName == name

    if bothDirections
      t = @$table.$workspace.getTable(name,false)
      if t
        res = t.$relations.getForTable(@$table.$name)
        return res if res

    undefined