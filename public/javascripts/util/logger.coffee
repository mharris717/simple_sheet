window.logger = {
  log: (str) -> 
    console.debug(str)
    #$('#log').prepend(str+"<br>")

  debug: (str) ->
    a=2
}
