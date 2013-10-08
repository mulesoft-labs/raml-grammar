{TreeMap, NodeMap, transverse, root, transversePrimitive} = require './main.coffee'

printRAMLGrammar = ->
  result = {}
  id = (x) -> x.constructor.name

  addPrimeTillEmpty = (result, key, metadata) ->
    if not result[key]
      key
    else
      addPrimeTillEmpty(result, key + '\'')

  class StringNode
    @toString: ->
      '<any string>'

  class StringNodeMap extends NodeMap
    @markdown: id
    @include: id
    @jsonSchema: id
    @regex: id
    @integer: id
    @boolean: id
    @xmlSchema: id
    @stringNode: -> StringNode
    @constantString: (root) -> root.value
    

  class StringTreeMap extends TreeMap
    @alternatives: (root, alternatives) -> alternatives.join(' | ')
    @tuple: (root, key, value) ->
      switch key
        when StringNode
          "(<any string>, #{value})"
        else
          oldKey = key
          key = addPrimeTillEmpty(result, key, root.metadata.category)
          result[key] = "(\"#{oldKey}\", #{value})"
          key
    @multiple: (root, element) -> "(#{element})*"
    @postponedExecution: id
    @node: (root) -> transversePrimitive(StringNodeMap, root)
    @list: (root, elements) -> "[#{elements}]"

  parentNode = transverse StringTreeMap, root
  s = ("#{key}: #{value}" for key, value of result).join('\n\n')
  s += "\n\nroot: #{parentNode}"
  s

console.log do printRAMLGrammar
