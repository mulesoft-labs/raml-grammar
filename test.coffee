# TODO Move this to tests
#console.log transverse(TreeMapToString, root)

class TreeMapToSuggestionTree extends TreeMap
  @alternatives: (root, alternatives) ->
    d = {}
    for alternative in alternatives
      for key, value of alternative
        d[key] = value
    d

  @multiple: (root, element) ->
    element

  @tuple: (root, key, value) ->
    d = {}
    kind = typ3(key)
    switch kind
      when 'Array'
        for k in key
          switch typ3(k)
            when 'string'
              d[k] = () -> value
            else 
              throw k
      when 'object'
        for k in key
          switch typ3(k)
            when 'string'
              d[k] = () -> value
            else
              throw k
      else 
        if typ3(value) != 'function'
          d[key] = () -> value
        else
          d[key] = value
    d

  @primitiveAlternatives: (root, alternatives) ->
    alternatives

  @postponedExecution: (root, execution) ->
    execution.f

  @node: (root) ->
    transversePrimitive NameNodeMap, root

  @string: (root) ->
    root
 
# TODO Move this to tests
#console.log suggest(suggestionTree, 0, ['/pet', '/hello', '/bye', 'get', 'queryParameters', 'limit', 'default'])

# TODO Move this ot test
class TreeMapToString extends TreeMap
  @constructor: () ->
    @i = 0
  
  @getSpaces: () -> 
    (' ' for num in [1..@i]).join('')
  
  @alternatives: (root, alternatives) -> 
    @i = @i + 1
    res =  '(' + @getSpaces() + alternatives.join(' | ') + ')'
    @i = @i - 1
    res

  @tuple: (root, key, value) -> 
    @i = @i + 1
    res = '(' + key + ': ' + value + ')'
    @i = @i - 1
    res

  @multiple: (root, element) -> 
    @i = @i + 1
    res = '[' + @getSpaces() + element + ']'
    @i = @i - 1
    res
  
  @primitiveAlternatives: (root, alternatives) ->
    @i = @i + 1
    res =  '(' + @getSpaces() + alternatives.join(' | ') + ')'
    i = @i - 1
    res
  
  @postponedExecution: (root, promise) ->
    promise
  
  @node: (root) ->
    root.constructor.name
  
  @string: (root) ->
    root

