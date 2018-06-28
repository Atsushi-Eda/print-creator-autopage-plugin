$      = global.jQuery
_      = require 'lodash'
u      = require '../../utils'
t      = require '../i18n'
api    = require '../../components/print-creator/api'
config = require '../../config'

Batch =
  canSubmit: false
  createDOM: ->
    # create dom
    $container = $('<div class="pcreator-container pcreator-container-new-ui"></div>')
    $selectWrapper = $('<div class="kintoneplugin-select"></div>')
    $select = $('<select class="pcreator-sheets-select"></select>')
    $form = $('<form method="POST" target="_blank"></form>')
    $data = $('<input type="hidden" name="data" value=""/>')
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
      data = {}
      data.user = kintone.getLoginUser()
      sheetId = $select.val()
      autoSheet = _.find config.autoSheets, (s) ->
        +s.subSheets[0].sheet is +sheetId
      url = u.makeUrl "sheet/#{sheetId}/output/multi?appCode=#{config.appCode}"

      if !data.user.email
        alert (t._ 'unknown_email')
        return false
      if Batch.canSubmit
        Batch.canSubmit = false
        return true

      kintone.api kintone.api.url('/k/v1/records', true),
        'GET',
        app: kintone.app.getId()
        query: kintone.app.getQueryCondition() + (" limit 1 offset 501"),
        (res) ->
          if res.records.length
            alert (t._ 'invalid_query')
            return false

          kintone.api kintone.api.url('/k/v1/records', true),
            'GET',
            app: kintone.app.getId()
            query: kintone.app.getQuery().replace(/limit ([0-9]+)/, 'limit 500').replace(/offset ([0-9]+)/, 'offset 0'),
            (res) ->
              u.log 'records:', res.records
              data.records = res.records
              _.each data.records, (r) ->
                if autoSheet? and r[autoSheet.tableField]?.value?.length?
                  l = r[autoSheet.tableField]?.value.length
                  sub = _.find autoSheet.subSheets, (s) ->
                    +s.from <= l and +s.to >= l
                  if not sub?
                    alert l + "行に当たる設定がありません"
                    return false
                  r.pcLedgerSheetId = sub.sheet

              $form.attr('action', url)
              data.user = kintone.getLoginUser()
              $data.val JSON.stringify(data)
              Batch.canSubmit = true
              $form.submit()
      false

    $container

module.exports = Batch