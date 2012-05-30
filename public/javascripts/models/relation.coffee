RelationOption = Em.Object.extend
  rowFromTable: (t) ->
    res = @$rows[t]

  fields: ->
    @$$relation.$$baseTable.$$workspace.$$fields

  matches: (str) ->
    res = Eval.evalFormula(this,str,@fields())
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

  toJson: ->
    {otherTableName: @$otherTableName, formula: @$formula, baseTableName: @$baseTable.$name}

  hydrate: (raw) ->
    @set k,v for k,v of raw



  getRows: (baseRow) ->
    res = []
    for otherRow in @otherTable(baseRow).$rows.$content
      if true #!res
        rows = {}
        rows[baseRow.$table.$name] = baseRow
        rows[otherRow.$table.$name] = otherRow
        option = RelationOption.create(relation: this, rows: rows)
        res.push(otherRow) if option.matches(@$formula)
    res

app.Relations = Em.ArrayController.extend
  init: ->
    @set 'content', []

  add: (otherTable, formula) ->
    throw "no table" if isBlank(otherTable)
    throw "no formula" if isBlank(formula)
    ops = {baseTable: @$table, otherTableName: otherTable, formula: formula}
    r = app.Relation.create(ops)
    @pushObject r

  getForTable: (name,bothDirections=true) ->
    for rel in @content
      return rel if rel.$otherTableName == name

    if bothDirections
      throw "no table" if isBlank(@$table)
      throw "no workspace" if isBlank(@$table.$workspace)
      t = @$table.$workspace.getTable(name,false)
      if t
        res = t.$relations.getForTable(@$table.$name,false)
        return res if res

    undefined

  relatedTables: ->
    res = []
    if @$table.$workspace
      for table in @$$table.$$workspace.$$tables.$$content
        res.push(table) if @getForTable(table.$name)
    res