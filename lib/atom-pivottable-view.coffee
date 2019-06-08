path = require 'path'
{CompositeDisposable, Disposable} = require 'atom'
{ScrollView}  = require 'atom-space-pen-views'
_ = require 'lodash'
jQuery = require 'jquery'
window.$ = window.jQuery = jQuery
require 'jquery-ui-dist/jquery-ui'
pivot = require 'pivottable'
JSON5 = require 'json5'
csv_parse = require 'csv-parse/lib/sync'

module.exports =
  PIVOT_PROTOCOL: "pivot-table:"
  PivottableView: class PivottableView extends ScrollView

    editorSub           : null
    onDidChangeTitle    : -> new Disposable()
    onDidChangeModified : -> new Disposable()

    @content: ->
      @div class: 'atom-pivottable native-key-bindings', tabindex: -1

    constructor: ({ @editorId, filePath }) ->
      super

      if @editorId?
        @resolveEditor(@editorId)
      else
        if atom.workspace?
          @subscribeToFilePath(filePath)
        else
          atom.packages.onDidActivatePackage =>
            @subscribeToFilePath(filePath)

    destroy: ->
      @editorSub.dispose()

    subscribeToFilePath: (filePath) ->
      atom.commands.dispatch 'atom-pivottable', 'title-changed'
      @handleEvents()
      @renderHTML()

    resolveEditor: (editorId) ->
      resolve = =>
        @editor = @editorForId(editorId)

        if @editor?
          atom.commands.dispatch 'atom-pivottable', 'title-changed'
          @handleEvents()
        else
          atom.workspace?.paneForItem(this)?.destroyItem(this)

      if atom.workspace?
        resolve()
      else
        atom.packages.onDidActivatePackage =>
          resolve()
          @renderHTML()

    editorForId: (editorId) ->
      for editor in atom.workspace.getTextEditors()
        return editor if editor.id?.toString() is editorId.toString()
      null

    handleEvents: =>
      changeHandler = =>
        @renderHTML()
        pane = atom.workspace.paneForURI(@getURI())
        if pane? and pane isnt atom.workspace.getActivePane()
          pane.activateItem(this)

      @editorSub = new CompositeDisposable

      if @editor?
        @editorSub.add @editor.onDidChange _.debounce(changeHandler, 700)
        @editorSub.add @editor.onDidChangePath =>
          atom.commands.dispatch 'atom-pivottable', 'title-changed'

    renderHTML: ->
      return unless @editor?

      @html ""
      _.each @parseData(), (data, i)=>
        id = "pivottable-#{++i}"
        element = jQuery "<div />",
          html: [
            jQuery("<div />", text: data.title, class: "title"),
            jQuery("<div />", id: id),
          ]

        @append element
        row = data.data[0]
        data.data = @convertToObject(data.data) if _.isArray(row)
        keys = @pivotAttrs(data.data)
        jQuery("##{id}").pivotUI data.data,
          rows: [keys[1]],
          cols: [keys[0]],
          rendererName: "Heatmap"

    parseData: ->
      data = @editor.getText()
      parsed_data = @parseJSON(data)
      return parsed_data if parsed_data
      parsed_data = @parseCSV(data)
      return parsed_data if parsed_data
      return []

    parseJSON: (data)->
      try
        data = JSON5.parse(data)
        return [{ title: "", data: data }] if _.isArray(data)

        foo = _.map data, (value, key)->
          return null if !_.isArray(value) || _.isEmpty(value)
          { title: key, data: value }

        return _.compact(foo)
      catch error
        return false

    parseCSV: (data)->
      # Support CSV or TSV
      try
        data = csv_parse(data)
      catch error
        try
          data = csv_parse(data, { delimiter: "\t" })
        catch error
          return false

      # must be having 2 rows and 2 columns
      return [] if data.length < 2 || data[0].length < 2
      return [{ title: "", data: data }]

    convertToObject: (data)->
      _.times data.length - 1, (i)->
        _.zipObject(data[0], data[i + 1])

    pivotAttrs: (data)->
      row = data[0]
      attrs = []
      _.each _.keys(row), (attr)->
        nums = _.keys(_.countBy(data, attr)).length
        attrs.push(attr) if nums > 1 && nums < 10
        # Break each
        return false if attrs.length >= 2
      attrs

    getTitle: ->
      if @editor?
        "#{@editor.getTitle()} Pivot Table"
      else
        "Pivot Table"

    getURI: ->
      "pivot-table://editor/#{@editorId}"
