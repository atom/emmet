CSON = require 'season'
path = require 'path'
emmet = require '../vendor/emmet-core'
editorProxy = require './editor-proxy'
actions = emmet.require("actions")
emmet.define('file', require('./file'));

module.exports =
  editorSubscription: null

  activate: (@state) ->
    unless @actionTranslation
      @actionTranslation = {}
      keymapObj = CSON.readFileSync(path.join(__dirname, "../keymaps/emmet.cson"))[".editor"]
      for key of keymapObj
        # Atom likes -, but Emmet expects _
        action = keymapObj[key]
        emmet_action = action.split(":")[1].replace(/\-/g, "_")
        @actionTranslation[action] = emmet_action

    @editorSubscription = rootView.eachEditor (editor) =>
      if editor.attached and not editor.mini

        for action, emmetAction of @actionTranslation
          editor.command action, (e) =>
            # a better way to do this might be to manage the editorProxies
            # right now we are resetting up the proxy each time
            editorProxy.setupContext(editor)
            syntax = editorProxy.getSyntax()
            if emmetAction == 'expand_abbreviation_with_tab' && !emmet.require("resources").hasSyntax(syntax)
              editor.insertText(editor.activeEditSession.getTabText())
            else
              actions.run(emmetAction, editorProxy)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
