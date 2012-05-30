if false
  jQuery.noConflict()
  jQuery('.card-none, .card-treasure').live 'click', ->
    me = jQuery(this)
    alert(me.text())