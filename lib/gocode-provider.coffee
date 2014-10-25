childProcess = require "child_process"
{Provider, Suggestion} = require "autocomplete-plus"

module.exports =
class GocodeProvider extends Provider
  buildSuggestions: (cb) ->
    cursor = @editor.getCursorBufferPosition()
    offset = @editor.getBuffer().characterIndexForPosition(cursor)

    result = childProcess.spawnSync "gocode", ["-f=json", "autocomplete", offset],
      input: @editor.getText()

    if result.error or result.status
      console.log "failed to run gocode:", result
      return

    res = JSON.parse(result.stdout)

    numPrefix = res[0]
    candidates = res[1]

    return unless candidates

    suggestions = []
    for c in candidates
      prefix = c.name.substring 0, numPrefix

      word = c.name
      word += "(" if c.class is "func"

      suggestions.push new Suggestion(this, word: word, prefix: prefix, label: c.type, data: c.class)

    return suggestions
