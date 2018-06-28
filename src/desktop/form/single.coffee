$      = global.jQuery
_      = require 'lodash'
u      = require '../../utils'
t      = require '../i18n'
api    = require '../../components/print-creator/api'
config = require '../../config'

Single =
  createDOM: ->
    # create dom
    $container = $('<div class="pcreator-container pcreator-container-new-ui"></div>')
    $selectWrapper = $('<div class="kintoneplugin-select"></div>')
    $select = $('<select class="pcreator-sheets-select"></select>')
    $form = $('<form method="POST" target="_blank"></form>')
    $data = $('<input type="hidden" name="record" value=""/>')
    $submit = $('<input type="submit" value=\"' + (t._ 'output') + '\" class="pcreator-submit-new-ui" />')
    $data.appendTo $form
    $submit.appendTo $form
    $select.appendTo $selectWrapper
    $selectWrapper.appendTo $container
    $form.appendTo $container

    # add sheets
    api.fetchSheets config.appCode, 0, (sheets) ->
      u.log 'sheets:', sheets
      showSheets = _.filter sheets, (sheet) ->
        $.inArray("#{sheet.id}", config.showSheets) >= 0

      _.forEach showSheets, (sheet) ->
        $op = $ "<option value=\"#{sheet.id}\">#{sheet.title}</option>"
        $select.append $op
        $select.removeAttr "disabled"
        $submit.removeAttr "disabled"

      if showSheets.length  is 0
        $op = $ "<option value=\"\">" + (t._ 'sheets_not_exist') + "</option>"
        $select.append $op
        $select.attr disabled: "disabled"
        $submit.attr disabled: "disabled"

    # submit
    $form.submit ->
      sheetId = $select.val()
      autoSheet = _.find config.autoSheets, (s) ->
        +s.subSheets[0].sheet is +sheetId

      url = u.makeUrl "sheet/#{sheetId}/output?appCode=#{config.appCode}"
      record = kintone.app.record.get() or {record: []}
      if autoSheet? and record.record[autoSheet.tableField]?.value?.length?
          l = record.record[autoSheet.tableField]?.value.length
          sub = _.find autoSheet.subSheets, (s) ->
            +s.from <= l and +s.to >= l
          if not sub?
            alert l + "行に当たる設定がありません"
            return false
          sheetId = sub.sheet
          url = u.makeUrl "sheet/#{sheetId}/output?appCode=#{config.appCode}"

      $form.attr('action', url)
      record.recordId = kintone.app.record.getId()
      record.user = kintone.getLoginUser()
      data = JSON.stringify(record)
      $data.val data

    $container

module.exports = Single