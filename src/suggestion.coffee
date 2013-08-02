{typ3: type} = require './utils.coffee'
{TreeMap, NodeMap, transverse, root, transversePrimitive} = require './main.coffee'

class Suggestion

class SimpleSuggestion extends Suggestion
  constructor: (@suggestions) ->

class OpenSuggestion extends Suggestion
  constructor: (@suggestions, @open) ->

class SuggestItem
  constructor: (@open, @name, @category='spec') ->

class StringWildcard

stringWilcard = new StringWildcard

class SuggestionNodeMap extends NodeMap
  name = (node) -> node.constructor.name
  @markdown: name
  @include: name
  @jsonSchema: name
  @regex: name
  @integer: name
  @boolean: name
  @xmlSchema: name
  @stringNode: () -> stringWilcard
  @constantString: (root) -> root.value

functionize = (value) -> if type(value) == 'function' then value else () -> value

class Tuple
  constructor: (@key, @value) ->

class TreeMapToSuggestionTree extends TreeMap
  @alternatives: (root, alternatives) ->
    d = {}
    for alternative in alternatives
      switch
        #when alternative instanceof Tuple
        #  key = alternative.key
        #  value = alternative.value
        #  if key == stringWilcard
        #    open = value
        #  else
        #    d[key] = value
        when alternative instanceof SimpleSuggestion
          ((d[key] = value) for key, value of alternative.suggestions)
        when alternative instanceof OpenSuggestion
          ((d[key] = value) for key, value of alternative.suggestions)
          open = alternative.open
        else
          throw new Error('Invalid type: ' + alternatives)
    if open?
      new OpenSuggestion(d, () -> open())
    else 
      new SimpleSuggestion(d)

  @multiple: (root, element) -> 
    element

  @tuple: (root, key, value) -> 
    if key == stringWilcard
      new OpenSuggestion({}, functionize(value))
    else
      d = {}
      d[key] = new SuggestItem(functionize(value), key, root.category)
      new SimpleSuggestion(d)
      #new Tuple(key, new SuggestItem(functionize(value), key, root.category))

  @primitiveAlternatives: (root, alternatives) ->
    alternatives

  @postponedExecution: (root, execution) ->
    execution.f

  @node: (root) ->
    transversePrimitive(SuggestionNodeMap, root)


suggestionTree = transverse(TreeMapToSuggestionTree, root)

suggest = (root, index, path) ->
  key = path[index]

  if not key?
    return root
  
  val = if root.suggestions[key]? then root.suggestions[key].open() else root.open()

  suggest(val, index + 1, path)

suggestRAML = (path) ->
  suggest suggestionTree, 0, path

@suggestRAML = suggestRAML

window.suggestRAML = suggestRAML if typeof window != 'undefined'
