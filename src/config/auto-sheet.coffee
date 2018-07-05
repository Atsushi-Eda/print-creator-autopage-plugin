Vue = require 'vue'
_   = require 'lodash'
u   = require '../utils'
t   = require './i18n'

AutoSheet = Vue.extend
  template: require './templates/auto-sheet.html'
  replace: true
  inherit: true

  computed:
    computeSheet:
      get: ->
        if sheet?.id? then sheet.id else null
      set: (id) ->
        @sheet = _.find @sheets, {'id':id}

  methods:
    remove: ->
      @autoSheets.$remove @$index

  components:
    'sub-sheet': require './sub-sheet'

module.exports = AutoSheet