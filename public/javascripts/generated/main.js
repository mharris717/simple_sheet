(function() {
  var app;
  app = window.App;
  app.MainView = Ember.View.extend({
    templateName: "views_main",
    tableBinding: "App.table"
  });
  app.RowView = Ember.View.extend({
    templateName: "views_row",
    mouseDown: function(e) {
      console.debug("mouseDown");
      return console.debug(e);
    },
    mousedown: function(e) {
      console.debug("mouse down");
      return console.debug(e);
    },
    rightClick: function(e) {
      console.debug("mouse down");
      return console.debug(e);
    },
    rightclick: function(e) {
      console.debug("mouse down");
      return console.debug(e);
    },
    altclick: function(e) {
      console.debug("mouse down");
      return console.debug(e);
    },
    altClick: function(e) {
      console.debug("mouse down");
      return console.debug(e);
    }
  });
  app.NullView = Ember.View.extend({
    templateName: "views_null"
  });
  app.CatView = Ember.View.extend({
    templateName: "views_cat"
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
  app.HeaderView = Em.View.extend({
    workspaceBinding: "App.workspaces.current",
    templateName: "views_header",
    newTable: function(e) {
      return this.get('workspace').newTable();
    },
    showSettings: function(e) {
      return this.$('.settings').show();
    },
    makeFresh: function(e) {
      return app.workspaces.makeFresh();
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
