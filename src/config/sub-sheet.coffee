Vue = require 'vue'
_   = require 'lodash'
u   = require '../utils'
t   = require './i18n'

SubSheet = Vue.extend
  template: require './templates/sub-sheet.html'
  replace: true
  inherit: true

  computed:
    isNotFirst: ->
      @$index > 0
    isLast: ->
      @subSheets.length is @$index+1
    computeSubSheet:
      get: ->
        if sheet?.id? then sheets.id else null
      set: (id) ->
        @sheet = _.find @sheets, {'id':id}

  methods:
    remove: ->
      @subSheets.$remove @$index

    add: ->
      lastSubSheet = _.last @subSheets
      @subSheets.push
        from: +lastSubSheet.to + 1
        to: +lastSubSheet.to + 5
        sheet: @firstSheetId

module.exports = SubSheet