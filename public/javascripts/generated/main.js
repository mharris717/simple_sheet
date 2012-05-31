(function() {
  var app;
  app = window.App;
  app.MainView = Ember.View.extend({
    templateName: "views_main",
    tableBinding: "App.table",
    workspaceView: function() {
      return this._childViews[1];
    }
  });
  app.RowView = Ember.View.extend({
    templateName: "views_row"
  });
  app.CellView = Ember.View.extend({
    templateName: "views_cell",
    valueBinding: "cell.value",
    rawValueBinding: "cell.rawValue",
    editing: false,
    click: function(e) {
      this.set('editing', true);
      return mySetTimeout(function() {
        return this.$('input').focus();
      }, 100);
    },
    focusOut: function(e) {
      return this.set('editing', false);
    }
  });
  app.ColumnHeaderView = Ember.View.extend({
    templateName: "views_column_header",
    formulaBinding: 'column.formula',
    fieldBinding: 'column.field',
    click: function(e) {
      logger.log("columnHeader click");
      this.set('editing', true);
      return mySetTimeout(100, function() {
        return this.$('input').focus();
      });
    },
    focusOut: function(e) {
      logger.log("columnHeader focusOut");
      return this.set('editing', false);
    }
  });
  app.NewColumnHeaderView = Ember.View.extend({
    templateName: "views_new_column_header",
    show: function() {
      if (!this.get('wasClicked')) {
        logger.log("newColumn editing");
        this.set('editing', true);
        mySetTimeout(100, function() {
          return this.$('input').focus();
        });
        return this.set('wasClicked', true);
      } else {
        return logger.log("newColumn nothing");
      }
    },
    create: function(e) {
      logger.log("create on newColumn");
      this.set('editing', false);
      this.set('wasClicked', false);
      if (isPresent(this.get('field'))) {
        return this.get('table').addColumn(this.get('field'));
      }
    }
  });
  app.NewRowView = Ember.View.extend({
    templateName: "views_new_row",
    create: function(e) {
      logger.log("new row create");
      return this.get('table').addRow({});
    }
  });
  app.WorkspaceView = Em.View.extend({
    templateName: "views_workspace",
    newTable: function(e) {
      return this.get('workspace').newTable();
    }
  });
  app.WorkspaceNameView = Em.View.extend({
    templateName: "views_workspace_name",
    focusOut: function(e) {
      return this.get('parentView').set('editingName', false);
    }
  });
  app.HeaderView = Em.View.extend({
    workspaceBinding: "App.workspaces.current",
    templateName: "views_header",
    newTable: function(e) {
      this.get('workspace').newTable();
      return this.$('.settings').toggle();
    },
    showSettings: function(e) {
      return this.$('.settings').toggle();
    },
    makeFresh: function(e) {
      return app.workspaces.makeFresh();
    },
    manageRelations: function(e) {
      var v;
      v = app.Relation.ManageView.create({
        workspace: this.get('workspace')
      });
      v.append();
      return this.$('.settings').toggle();
    },
    newWorkspace: function(e) {
      var w;
      w = app.Workspace.create({
        name: 'Untitled'
      });
      w.save();
      app.workspaces.pushObject(w);
      app.workspaces.set('current', w);
      return this.$('.settings').toggle();
    },
    renameWorkspace: function(e) {
      this.get('parentView').workspaceView().set('editingName', true);
      return this.$('.settings').toggle();
    }
  });
  $(function() {
    var v;
    if (!testMode) {
      v = app.MainView.create();
      return v.append();
    }
  });
}).call(this);
