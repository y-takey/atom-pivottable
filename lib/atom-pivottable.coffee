url = require 'url'
{ PIVOT_PROTOCOL, PivottableView } = require './atom-pivottable-view'
{ CompositeDisposable } = require 'atom'

module.exports = AtomPivottable =
  PivottableView: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-pivottable:toggle': => @toggle()

    atom.workspace.addOpener (uriToOpen) ->
      try
        { protocol, host, pathname } = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is PIVOT_PROTOCOL

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
        new PivottableView(editorId: pathname.substring(1))
      else
        new PivottableView(filePath: pathname)

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    uri = "#{PIVOT_PROTOCOL}//editor/#{editor.id}"

    previewPane = atom.workspace.paneForURI(uri)
    if previewPane
      previewPane.destroyItem(previewPane.itemForURI(uri))
      return

    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (pivotView) ->
      if pivotView instanceof PivottableView
        pivotView.renderHTML()
        previousActivePane.activate()
