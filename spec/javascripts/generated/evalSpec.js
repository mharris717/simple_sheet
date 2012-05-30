(function() {
  describe('eval', function() {
    it('should do thing', function() {
      return expect(eval("2+2")).toEqual(4);
    });
    return it('has scope', function() {
      var a;
      a = 4;
      return expect(eval("a+2")).toEqual(6);
    });
  });
}).call(this);
