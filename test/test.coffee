{transverse, TreeMap, root} = require '../src/main.coffee'
{suggestRAML} = require '../src/suggestion.coffee'
{typ3: type} = require '../src/utils.coffee'
type = 
  of: type
should = (require '../node_modules/chai/index').should()

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

describe 'Tree Mapping', ->
  it 'should be able be used while transversing the tree', (done) ->
    mappedTree = transverse(TreeMapToString, root)
    done()

describe 'suggest',  ->
  it 'should handle root node', (done) ->
    suggestion = suggestRAML [] 
    suggestion.should.be.ok
    suggestion.should.have.property('suggestions')
    suggestions = suggestion.suggestions
    suggestions.title.should.be.ok
    done()
  it 'should handle an string value nodes', (done) ->
    suggestion = suggestRAML ['title']
    suggestion.should.be.ok
    done()
  it 'should handle nested resources', (done) ->
    suggestion = suggestRAML ['/hello', 'get']
    suggestion.should.be.ok
    done()
  it 'should work with resources nodes', (done) ->
    suggestion = suggestRAML ['/hello', '/this', '/{is}', '/a', '/resource']
    suggestion.should.have.property('suggestions')
    suggestions = suggestion.suggestions
    suggestions.should.include.keys('get', 'put', 'post', 'delete')

    get = suggestions.get
    get.should.have.property.open
    open = get.open
    type.of(open).should.be.equal('function')

    done()

  it 'should work with complex nested scenarios', (done) ->
    suggestion = suggestRAML ['/tags', '/search', 'get', 'headers', 'asd']
    suggestion.should.be.ok

    suggestions = suggestion.suggestions

    
    suggestions.should.include.keys('name', 'description', 
      'type', 'enum', 'pattern', 'minLength', 'maxLength', 'maximum', 'minimum', 'required',
      'default', 'requires', 'excludes', 'example')

    done()

  it 'should be weakly equal when called multiple times', (done) ->
    suggestion = suggestRAML ['/hello', '/this', '/{is}', '/a', '/resource']
    suggestion2 = suggestRAML ['/hello', '/this', '/{is}', '/a', '/resource']

    JSON.stringify(suggestion).should.be.equal(JSON.stringify(suggestion2))
    done()

  it 'should work with numerical fields', (done) ->
    suggestion = suggestRAML ['/hello', '/bye', 'get', 'responses']
    suggestion.should.be.ok
    suggestion.should.have.property('open')
    suggestions = suggestion.suggestions
    (Object.keys suggestions).length.should.be.equal(0)

    suggestion = suggestRAML ['/hello', '/bye', 'get', 'responses', '200']
    suggestion.should.be.ok
    suggestion.should.not.have.property('open')
    suggestions = suggestion.suggestions
    (Object.keys suggestions).should.include('body', 'description')
    done()


describe 'Category assignment', ->
  it 'should be "actions" for get, post, put and delete', (done) ->
    suggestion = suggestRAML ['/pet']
    suggestion.should.have.property('suggestions')
    suggestions = suggestion.suggestions
    suggestions.should.have.property(action) for action in ['get', 'put', 'post', 
      'delete']

    for methodName in ['get', 'put', 'post', 'delete']
      method = suggestions[methodName]
      method.should.have.property.open
      open = method.open
      type.of(open).should.be.equal('function')
      method.should.have.property('category')
      category = method.category
      category.should.be.equal('restful elements')
      suggestion = suggestRAML ['/pet', 'get']
    
    done()
    #catgories:
    #  actions
    #  resource data
    #  method parameters
    #  default: spec
    #  abajo de queryParameter no va nada -> ' '
    #  abajo de headers no va nada -> ' ' (a esa categoria va spec)
    #  abajo de responses no va nada -> ' '

