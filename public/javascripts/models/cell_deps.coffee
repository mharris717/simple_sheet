app.CellDeps = Em.Object.extend
  rowBinding: "cell.row"
  tableBinding: "cell.row.table"

  localDeps: ->
    v = @$value
    if v && v.match
      @$cell.$row.$table.$fields.filter (f) => v.match(f)
    else
      []

  getForeignFieldsFromFormula = (str) ->
    res = if str && str.match
      str.scan(/\$[a-z_]+\.[a-z_]+/) || []
    else
      []
    res.map (full) ->
      arr = full.substr(1,999).split(".")
      throw "not 2" unless arr.length == 2
      {table: arr[0], field: arr[1]}

  foreignDeps: ->
    getForeignFieldsFromFormula(@$value)
      
  
  cells: ->
    cellsForRelation = (aDep) =>
      res = []
      relation = @$cell.$row.$table.$relations.getForTable(aDep.table)
      table = @$cell.$row.$table.$workspace.getTable(aDep.table)
      if relation
        for dep in getForeignFieldsFromFormula(relation.$formula)
          if dep.table != @$cell.$row.$table.$name
            res.push([table,"rows.@each.#{dep.field}"])
      res

    deps = @localDeps()
    res = @$cell.$row.$cellsInner.filter (cell) => _.include(deps,cell.$field)

    foreign = []
    for dep in @foreignDeps()
      foreignRow = @$cell.$row.rowFromTable(dep.table)
      #throw "no row for #{dep.table}" unless foreignRow
      if foreignRow
        if foreignRow.cellsForField
          foreign = foreign.concat(foreignRow.cellsForField(dep.field))
        else
          foreign.push foreignRow.cellForField(dep.field)
        #foreign.push([foreignRow.$table,'countCell'])
        foreign = foreign.concat(cellsForRelation(dep))



    #logger.log "depCells for #{@$field} #{res.length} #{@$row.$cells.length} #{@deps().length}"
    res.concat(foreign)

  setupObservers: ->
    #return if @$cell.$row.$table.$hydrating
    for cell in @cells()
      #logger.debug "adding observer from #{@$field} to #{cell.$field}"
      if cell.length && cell.length == 2
        cell[0].removeObserver cell[1],@$cell,@$cell.recalcSpecial
        cell[0].addObserver cell[1],@$cell,@$cell.recalcSpecial
      else
        cell.removeObserver 'value',@$cell,@$cell.recalc
        cell.addObserver 'value',@$cell,@$cell.recalc

    @$cell.$row.$table.$formulas.removeObserver @$cell.$field, @$cell, @$cell.recalc
    @$cell.$row.$table.$formulas.addObserver @$cell.$field, @$cell, @$cell.recalc

    #@$cell.$row.$table.$workspace.getTable('stats').

