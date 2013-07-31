{TreeMap, suggest, suggestionTree, transverse, root} = require './suggest'


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

describe 'Tree Mapping', ->
  it 'should be able be used while transversing the tree', (done) ->
    mappedTree = transverse(TreeMapToString, root)
    done()

describe 'suggest',  ->
  it 'should handle "title"', (done) ->
    suggest suggestionTree, 0, ['title'] 
    done()
  it 'should work with resources', (done) ->
    suggest suggestionTree, 0, ['/hello', '/this', '/{is}', '/a', '/resource']
    done()
