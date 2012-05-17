window.logger = {
  log: (str) -> 
    console.debug(str)
    #$('#log').prepend(str+"<br>")

  debug: (str) ->
    #@log(str)
}
