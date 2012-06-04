app.MainView = Ember.View.extend
  templateName: "views_main"
  tableBinding: "App.table"

  workspaceView: ->
    @_childViews[1]

app.RowView = Ember.View.extend
  templateName: "views_row"

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
    @$table.addColumnWithFieldParsing(@$field)
        

app.NewRowView = Ember.View.extend
  templateName: "views_new_row"

  create: (e) ->
    logger.log "new row create"
    @$table.addRow({})

app.WorkspaceView = Em.View.extend
  templateName: "views_workspace"

  newTable: (e) ->
    @$workspace.newTable()

app.WorkspaceNameView = Em.View.extend
  templateName: "views_workspace_name"

  focusOut: (e) ->
    @$parentView.set 'editingName', false

app.HeaderView = Em.View.extend
  workspaceBinding: "App.workspaces.current"
  templateName: "views_header"

  newTable: (e) ->
    @$workspace.newTable()
    this.$('.settings').toggle()

  showSettings: (e) ->
    this.$('.settings').toggle()

  makeFresh: (e) ->
    app.workspaces.makeFresh()

  manageRelations: (e) ->
    v = app.Relation.ManageView.create(workspace: @$workspace)
    #ge = $('#general-edit')
    #ge.html('')
    v.append()
    this.$('.settings').toggle()

  newWorkspace: (e) ->
    w = app.Workspace.create(name: 'Untitled')
    w.save()
    app.workspaces.pushObject(w)
    app.workspaces.set 'current',w
    this.$('.settings').toggle()

  renameWorkspace: (e) ->
    @$parentView.workspaceView().set 'editingName', true
    this.$('.settings').toggle()


$ ->  
  #t = makeFreshTable()
  #t.save()
  #app.set 'workspace', getWorkspace()
  #app.set 'table', makeFreshTable()
  #app.set 'table', app.Table.load()
  unless testMode
    v = app.MainView.create()
    v.append()
    
