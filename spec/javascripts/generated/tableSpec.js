(function() {
  describe('Stuff', function() {
    it('smoke', function() {
      return expect(window.App).toBeDefined();
    });
    describe('widgets', function() {
      var lastRow, row, table;
      row = table = lastRow = null;
      describe("from widgets table", function() {
        beforeEach(function() {
          var workspace;
          getWorkspacesFresh();
          workspace = getWorkspaces()[1];
          table = workspace.get('tables').get('content')[0];
          row = table.get('rows').get('content')[0];
          lastRow = table.get('rows').get('content')[2];
          return table.setupAll();
        });
        it('smoke', function() {
          return expect(row.getCellValue('price')).toEqual(20);
        });
        it('relation', function() {
          var res;
          res = row.evalInContext("$depts.min_prc");
          return expect(res).toEqual(50);
        });
        return it('relation2', function() {
          var res;
          res = lastRow.evalInContext("$depts.min_prc");
          return expect(res).toEqual(100);
        });
      });
      return describe("from depts table", function() {
        beforeEach(function() {
          var workspace;
          workspace = getWorkspaces()[1];
          table = workspace.get('tables').get('content')[1];
          row = table.get('rows').get('content')[0];
          lastRow = table.get('rows').get('content')[1];
          return table.setupAll();
        });
        it('phantom table returns no row', function() {
          return expect(row.rowFromTable('sdfsdf')).toBeUndefined();
        });
        return it('works other direction', function() {
          return expect(row.rowFromTable('widgets')).toBeDefined();
        });
      });
    });
    describe("new column", function() {
      var lastRow, row, table;
      row = table = lastRow = null;
      beforeEach(function() {
        var workspace;
        getWorkspacesFresh();
        workspace = getWorkspaces()[0];
        table = workspace.get('tables').get('content')[0];
        row = table.get('rows').get('content')[0];
        return table.setupAll();
      });
      it('parses formula', function() {
        var hr;
        table.addColumnWithFieldParsing("zzz=hr");
        hr = row.getCellValue('hr');
        return expect(row.getCellValue('zzz')).toEqual(hr);
      });
      return it('parses formula multiple =', function() {
        table.addColumnWithFieldParsing("zzzz=if 2 == 3 then 10 else 20");
        return expect(row.getCellValue('zzzz')).toEqual(20);
      });
    });
    describe('sum across relation', function() {
      var players, row, stats;
      row = players = stats = null;
      beforeEach(function() {
        var workspace;
        workspace = getWorkspaces()[0];
        stats = workspace.get('tables').get('content')[0];
        players = workspace.get('tables').get('content')[1];
        players.addColumn('pa', '=$stats.pa');
        row = players.get('rows').get('content')[0];
        return players.setupAll();
      });
      it('should sum', function() {
        var res;
        res = row.evalInContext("$stats.hr.sum");
        return expect(res).toEqual(40);
      });
      it('should sum 2', function() {
        var res;
        res = row.getCellValue('pa');
        return expect(res).toEqual(1200);
      });
      return describe("bunch", function() {
        var i, _results;
        _results = [];
        for (i = 0; i < 1; i++) {
          describe('new stats row - fully formed', function() {
            beforeEach(function() {
              var c;
              c = row.cellForField('pa');
              c.set('rawValue', " ");
              row.getCellValue('pa');
              return stats.addRow({
                name: 'Ted Williams',
                year: 1957,
                pa: 600,
                hr: 10
              });
            });
            return it('should sum to new value', function() {
              var res;
              res = row.getCellValue('pa');
              return expect(res).toEqual(1800);
            });
          });
          _results.push(describe('new stats row - not fully formed', function() {
            beforeEach(function() {
              var c;
              c = row.cellForField('pa');
              c.set('rawValue', " ");
              row.getCellValue('pa');
              return Ember.run(function() {
                var newRow;
                newRow = stats.addRow({
                  name: 'Ted Williamsx',
                  year: 1957,
                  pa: 600,
                  hr: 10
                });
                return newRow.set('name', 'Ted Williams');
              });
            });
            return it('should sum to new value', function() {
              var res;
              res = row.getCellValue('pa');
              return expect(res).toEqual(1800);
            });
          }));
        }
        return _results;
      });
    });
    return describe('baseball', function() {
      var bavg, h, row, table;
      row = h = bavg = table = null;
      beforeEach(function() {
        var workspace;
        workspace = getWorkspaces()[0];
        table = workspace.get('tables').get('content')[0];
        row = table.get('rows').get('content')[0];
        h = row.cellForField('h');
        bavg = row.cellForField('bavg');
        if (!row) {
          noRow;
        }
        if (!h) {
          noHField;
        }
        window.bavg = bavg;
        return table.setupAll();
      });
      describe("basic", function() {
        return it('h', function() {
          return expect(h.get('value')).toEqual(165);
        });
      });
      if (true) {
        describe("basic value changes", function() {
          it('h', function() {
            return expect(h.get('value')).toEqual(165);
          });
          it('bavg', function() {
            return expect(bavg.get('value')).toEqual(0.314);
          });
          it('bavg changes when h changes', function() {
            h.set('rawValue', 200);
            return expect(bavg.get('value')).toEqual(roundNumber(200.0 / 525.0, 3));
          });
          it("bavg changes when formula changes", function() {
            bavg.set('rawValue', "=h/ab*2");
            return expect(bavg.get('value')).toEqual(0.629);
          });
          return it('long', function() {
            var i, _results;
            _results = [];
            for (i = 0; i < 10; i++) {
              _results.push(h.set('rawValue', i));
            }
            return _results;
          });
        });
        describe("column formula", function() {
          it('should change cell value', function() {
            expect(bavg.get('value')).toEqual(0.314);
            Ember.run.begin();
            table.setFormula('bavg', '=5');
            Ember.run.end();
            return expect(bavg.get('value')).toEqual(5);
          });
          it('should not change cell value if cell has own raw value', function() {
            expect(bavg.get('value')).toEqual(0.314);
            bavg.set('rawValue', '=14');
            table.setFormula('bavg', '=5');
            return expect(bavg.get('value')).toEqual(14);
          });
          return it('can set column formula as a constant', function() {
            table.setFormula('bavg', 9);
            return expect(bavg.get('value')).toEqual(9);
          });
        });
        describe("new column", function() {
          return it('something', function() {
            table = makeFreshTable();
            table.addColumn('iso', "=slg-bavg");
            row = table.get('rows').get('content')[0];
            return expect(row.getCellValue('iso')).toEqual(0.151);
          });
        });
      }
      return describe("row from another table", function() {
        it('smoke', function() {
          return expect(row.rowFromTable('players')).toBeDefined();
        });
        it('formula', function() {
          var formula, res;
          formula = "if $players.side == 'L' then 10 else 20";
          res = row.evalInContext(formula);
          return expect(res).toEqual(10);
        });
        return describe("multiple related rows", function() {});
      });
    });
  });
}).call(this);
