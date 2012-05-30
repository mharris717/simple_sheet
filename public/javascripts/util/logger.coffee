window.logger = {
  log: (str) -> 
    console.debug(str) unless isBlank(str)
    #$('#log').prepend(str+"<br>")

  debug: (str) ->
    #@log(str)
}
