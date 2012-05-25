app.MainView = Ember.View.extend
  templateName: "views_main"
  tableBinding: "App.table"

app.RowView = Ember.View.extend
  templateName: "views_row"

app.NullView = Ember.View.extend
  templateName: "views_null"
  
app.CatView = Ember.View.extend
  templateName: "views_cat"
  
app.CellView = Ember.View.extend
  templateName: "views_cell"
  valueBinding: "cell.value"
  rawValueBinding: "cell.rawValue"

  editing: false
  
  click: (e) ->
    @set('editing',true)
    mySetTimeout -> 
      @.$('input').focus()
    ,100
    
  focusOut: (e) -> 
    @set('editing',false)

app.ColumnHeaderView = Ember.View.extend
  templateName: "views_column_header"

  formulaBinding: 'column.formula'
  fieldBinding: 'column.field'

  click: (e) ->
    logger.log "columnHeader click"
    @set('editing',true)
    mySetTimeout 100, -> @.$('input').focus()
    
  focusOut: (e) -> 
    logger.log "columnHeader focusOut"
    @set('editing',false)

app.NewColumnHeaderView = Ember.View.extend
  templateName: "views_new_column_header"

  show: ->
    if !@$wasClicked
      logger.log "newColumn editing"
      @set('editing',true)
      mySetTimeout 100, -> @.$('input').focus()
      @set('wasClicked',true)
    else
      logger.log "newColumn nothing"

  create: (e) ->
    logger.log "create on newColumn"
    @set('editing',false)
    @set('wasClicked',false)
    if isPresent(@$field)
      @$table.addColumn(@$field)

app.NewRowView = Ember.View.extend
  templateName: "views_new_row"

  create: (e) ->
    logger.log "new row create"
    @$table.addRow({})

app.WorkspaceView = Em.View.extend
  templateName: "views_workspace"

app.TableView = Em.View.extend
  templateName: "views_table"

$ ->  
  #t = makeFreshTable()
  #t.save()
  app.set 'workspace', getWorkspace()
  #app.set 'table', makeFreshTable()
  #app.set 'table', app.Table.load()
  unless testMode
    v = app.MainView.create()
    v.append()
    