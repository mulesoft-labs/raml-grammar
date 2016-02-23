class SuggestionItem
  constructor: (@key, @suggestor, @metadata = {}) ->

  matches: (key) ->
    @key == key || @metadata.canBeOptional && @key + '?' == key

class Suggestor
  constructor: (@items, @fallback, @metadata = {}) ->
    @fallback ?= ->

  suggestorFor: (key) ->
    matchingItems = @items.filter (item) -> item.matches(key)

    if matchingItems.length > 0
      matchingItems[0].suggestor
    else
      @fallback(key)

  suggestions: ->
    suggestions = {}
    for item in @items
      suggestions[item.key] = {
        metadata: item.metadata
      }

    suggestions

class EmptySuggestor extends Suggestor
  constructor: (fallback) ->
    super [], fallback

class UnionSuggestor
  constructor: (@suggestors, @fallback) ->
    @fallback ?= ->

  suggestorFor: (key) ->
    for suggestor in @suggestors
      if suggestor = suggestor.suggestorFor key
        return suggestor

    @fallback key

  suggestions: ->
    suggestions = {}

    for suggestor in @suggestors
      suggestorSuggestions = suggestor.suggestions()
      for key, value of suggestorSuggestions
        suggestions[key] = value

    suggestions

# ---

module.exports.SuggestionItem = SuggestionItem
module.exports.Suggestor      = Suggestor
module.exports.EmptySuggestor = EmptySuggestor
module.exports.UnionSuggestor = UnionSuggestor

# ---

module.exports.noopSuggestor  = new EmptySuggestor()
