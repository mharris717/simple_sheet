app.Column = Ember.Object.extend
  init: ->
    @set 'incValue',0

  recalc: ->
    @incrementProperty('incValue')

  formula: ((k,v) ->
    if arguments.length == 1
      @$table.$formulas.get(@$field)
    else
      @$table.setFormula(@$field,v)
      v).property('table.formulas')

  values: (->
    @$table.$rows.map((row) -> row.getCellValue(@$field))).property('incValue')

  setupObservers: ->
    for row in @$table.$rows.$content
      cell = row.cellForField(@$field)
      cell.addObserver 'value',this,@recalc
    @$table.addObserver 'countCell',this,@recalc