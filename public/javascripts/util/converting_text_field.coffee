jQuery.fn.convertingTextField = ->
  @each ->
    field = $(this)
    label = $("<span>span label</span>")

    toggleVis = (showField) ->
      if showField
        label.hide()
        field.show()
      else
        label.show()
        field.hide()

    setLabelText = ->
      v = field.val()
      v = "____" if !v || v == ''
      label.text(v)

    setup = ->
      field.removeClass('converting')

      label.insertBefore(field)

      setLabelText()
      toggleVis false

      label.click ->
        toggleVis true

      field.change setLabelText

      field.blur ->
        setLabelText()
        toggleVis false

      setInterval setLabelText,500

    setup()

window.ConvertingTextField = Ember.TextField.extend
  classNames: ['ember-text-field','converting']

window.ConvertingSelect = Ember.Select.extend
  classNames: ['ember-select','converting']

#window.ConvertingTextArea = ExpandingTextArea.extend
#  classNames: ['ember-text-area','converting']

setInterval ->
  try
    $('input.converting').convertingTextField()
    $('textarea.converting').convertingTextField()
    $('select.converting').convertingTextField()
  catch error
    a=2
,500