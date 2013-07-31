
class TreeMapToSuggestionTree extends @TreeMap
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
 

suggestionTree = transverse(TreeMapToSuggestionTree, root)

suggest = (root, index,  path) ->
  key = path[index]

  if not path[index]?
    return root
    
  val = root[key] or root['StringNode']
  
  if typ3(val) == 'function'
      val = val()

  suggest(val, index + 1, path)

@suggestionTree = suggestionTree
@suggest = suggest
@transverse = transverse
@root = root
