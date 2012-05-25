describe 'eval', ->
  it 'should do thing', ->
    expect(eval("2+2")).toEqual(4)

  it 'has scope', ->
    a=4
    expect(eval("a+2")).toEqual(6)