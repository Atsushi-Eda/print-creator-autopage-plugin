Vue    = require 'vue'
_      = require 'lodash'
api    = require './api'
config = require './config'
u      = require './utils'

Vue.config.debug = config.debug

Main = Vue.extend
  template: require './templates/index.html'
  data: ->
      appCode: null
      sheets: []
      showSheets: []
      autoSheets: []
      kintoneFields: []

  computed:
    firstSheetId: ->
      s = _.first @sheets
      if s?.id? then s.id else null
    sheetOptions: ->
      options = []
      _.forEach @sheets, (s) ->
        options.push {text:s.title, value:s.id}
      options
    tableFields: ->
      _.filter @kintoneFields, (f) =>
        f.type is 'SUBTABLE'
    tableFieldOptions: ->
      options = []
      _.forEach @tableFields, (f) ->
        options.push {text:f.code, value:f.code}
      options

  methods:
    changeAppCode: (event) ->
      appCode = event.target.value
      @checkAppCode appCode
      if @appCode?
        @fetchSheets @appCode

    checkAppCode: (appCode) ->
      data = {
        appCode: appCode
        appId: kintone.app.getId()
      }
      u.log "checkAppCode:data:", data

      api.checkAppCode data, (err, res) =>
        u.log "checkAppCode:posted:", res
        u.log "checkAppCode:err", err
        kintone.plugin.app.setConfig({'appCode': appCode})
        @fetchSheets @appCode

    fetchSheets: (appCode) ->
      api.fetchSheets appCode, false, (err, sheets) =>
        @$set 'sheets', sheets

    addAutoSheet: ->
      tableField = _.first @tableFields
      if not tableField?.code?
        alert '自動改ページの設定テーブルフィールドが1つ以上必要です'
        return false
      autoSheet =
        tableField: tableField.code
        subSheets: []
      autoSheet.subSheets.push
        from: 1
        to: 5
        sheet: @firstSheetId
      @autoSheets.push autoSheet

    submit: ->
      params =
        appCode: @appCode
        showSheets: JSON.stringify @showSheets
        autoSheets: JSON.stringify @autoSheets
      u.log 'submit:', params
      kintone.plugin.app.setConfig params

  # created
  created: ->
    u.log 'Main created', @
    thisVM = @
    params = kintone.plugin.app.getConfig(config.pluginId)
    u.log 'params:', params
    config.appCode = params.appCode
    @$set 'appCode', params.appCode
    @$set 'showSheets', (if params.showSheets? then JSON.parse params.showSheets else [] )
    @$set 'autoSheets', (if params.autoSheets? then JSON.parse params.autoSheets else [] )

    if @appCode?
      @fetchSheets @appCode

    kintone.api kintone.api.url('/k/v1/form', true), 'GET', {app: kintone.app.getId()}, (res) ->
      thisVM.$set 'kintoneFields', res.properties

  components:
    'auto-sheet': require './auto-sheet'

new Main
  el: "#print-creator-plugin-config"
