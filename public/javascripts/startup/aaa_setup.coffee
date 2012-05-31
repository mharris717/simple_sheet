Ember.ENV.CP_DEFAULT_CACHEABLE = true
Ember.ENV.VIEW_PRESERVES_CONTEXT = true

window.testMode = true unless window.testMode == false
window.App = Ember.Application.create()
app = window.App