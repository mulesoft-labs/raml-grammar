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

  @postponedExecution: (root, promise) ->
    promise

  @node: (root) ->
    root.constructor.name

describe 'Tree Mapping', ->
  it 'should be able to be used while transversing the tree', (done) ->
    mappedTree = transverse(TreeMapToString, root)
    done()

describe 'suggest',  ->
  it 'should handle root node', (done) ->
    suggestion = suggestRAML []
    suggestion.should.be.ok
    suggestion.should.have.property('suggestions')
    {suggestions} = suggestion
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
    {suggestions} = suggestion
    suggestions.should.include.keys('get', 'put', 'post', 'delete')

    get = suggestions.get
    get.should.have.property.open
    open = get.open
    type.of(open).should.be.equal('function')

    done()

  it 'should work with complex nested scenarios', (done) ->
    suggestion = suggestRAML ['/tags', '/search', 'get', 'headers', 'asd']
    suggestion.should.be.ok

    {suggestions} = suggestion


    suggestions.should.include.keys('displayName', 'description',
      'type', 'enum', 'pattern', 'minLength', 'maxLength', 'maximum', 'minimum', 'required',
      'default', 'example')

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
    {suggestions} = suggestion
    (Object.keys suggestions).length.should.be.equal(0)

    suggestion = suggestRAML ['/hello', '/bye', 'get', 'responses', '200']
    suggestion.should.be.ok
    suggestion.should.not.have.property('open')
    {suggestions} = suggestion
    (Object.keys suggestions).should.include('body', 'description')
    done()

  it 'should tell me whether a node is an scalar or not', ->
    suggestion = suggestRAML ['/tags']
    suggestion.isScalar.should.be.equal false

    suggestion = suggestRAML ['title']
    suggestion.isScalar.should.be.equal true

    suggestion = suggestRAML ['/tags', 'displayName']
    suggestion.isScalar.should.be.equal true

  describe 'body', ->
    it 'should contain application/json and application/xml as sublevel suggestions (RT-81)', (done) ->
      suggestion = suggestRAML ['/hello', 'get', 'body']
      suggestion.should.be.ok
      {suggestions} = suggestion
      (Object.keys suggestions).should.include 'application/json', 'application/xml'
      done()

describe 'Methods', ->
  describe 'patch', ->
    it 'should be written correctly', ->
      suggestion = suggestRAML ['/hello']
      {suggestions} = suggestion
      suggestions.should.include.key 'patch'


describe 'Metadata', ->
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
        method.should.have.property('metadata')
        {metadata: {category}} = method
        category.should.be.equal('methods')
        suggestion = suggestRAML ['/pet', 'get']

      done()
  describe 'id', ->
    it 'should be assigned correctly to the resource node', ->
      suggestion = suggestRAML ['/pet']
      suggestion.should.have.property 'metadata'
      suggestion.metadata.should.be.ok
      {metadata: {id}} = suggestion
      id.should.be.ok
      id.should.be.equal 'resource'

describe 'InvalidState', ->
  # TODO Add tests of InvalidState here

describe 'cache', ->
  # TODO Add tests here

describe '0.2', ->
  describe 'Traits', ->
    it 'should support traits keyword', ->
      suggestion = suggestRAML ['traits']
      suggestion.should.be.ok
      suggestion.should.have.property('open')
      {suggestions} = suggestion
      (Object.keys suggestions).length.should.be.equal(0)

    it 'should support a particular trait definition', ->
      suggestion = suggestRAML ['traits', '- traitA']
      suggestion.should.be.ok
      suggestion.should.not.have.property('open')

    it 'should include the name property', ->
      suggestion = suggestRAML ['traits', '- traitA']
      {suggestions} = suggestion
      (Object.keys suggestions).should.include 'displayName'

    it 'should contain all the properties found in methods', ->
      suggestion = suggestRAML ['traits', '- traitA']
      {suggestions} = suggestion
      {suggestions: getMethodSuggestions} = suggestRAML ['/hello', 'get']
      suggestions.should.include.keys (Object.keys getMethodSuggestions)

    it 'should support nesting inside properties', ->
      suggestion = suggestRAML ['traits', 'traitA', 'responses']
      suggestion.should.be.ok
      suggestion.should.have.property 'open'
      {suggestions} = suggestion
      (Object.keys suggestions).length.should.be.equal(0)

      suggestion = suggestRAML ['traits', 'traitA', 'responses', '200']
      {suggestions} = suggestion
      suggestions.should.include.keys 'description'

    it 'should not offer "provides" or "requires" keywords', ->
      suggestion = suggestRAML ['traits', '- traitA']
      {suggestions} = suggestion
      suggestions.should.not.include.keys 'provides', 'requires'

  describe 'Resource Types', ->
    it 'should support resourceTypes keyword', ->
      suggestion = suggestRAML ['resourceTypes']
      suggestion.should.be.ok
      suggestion.should.have.property('open')
      {suggestions} = suggestion
      (Object.keys suggestions).length.should.be.equal(0)

    it 'should support a particular resourceType definition', ->
      suggestion = suggestRAML ['resourceTypes', '- collection']
      suggestion.should.be.ok
      suggestion.should.not.have.property('open')

    it 'should include displayName, description and type properties', ->
      suggestion = suggestRAML ['resourceTypes', '- collection']
      {suggestions} = suggestion
      (Object.keys suggestions).should.include 'displayName'
      (Object.keys suggestions).should.include 'description'
      (Object.keys suggestions).should.include 'type'

    it 'should contain all the properties found in a resource', ->
      suggestion = suggestRAML ['resourceTypes', '- collection']
      {suggestions} = suggestion
      {suggestions: resourceSuggestions} = suggestRAML ['/hello']

      suggestions.should.include.keys (Object.keys resourceSuggestions)

    it 'should support nesting inside properties', ->
      suggestion = suggestRAML ['resourceTypes', '- collection', 'get']
      suggestion.should.be.ok
      suggestion.should.not.have.property 'open'
      {suggestions} = suggestion
      {suggestions: getMethodSuggestions} = suggestRAML ['/hello', 'get']
      suggestions.should.include.keys (Object.keys getMethodSuggestions)

      suggestion = suggestRAML ['resourceTypes', '- collection', 'get', 'responses', '200']
      {suggestions} = suggestion
      suggestions.should.include.keys 'description'

    it 'should not allow nesting of resources', ->
      suggestion = suggestRAML ['resourceTypes', '- collection', '/hello']
      suggestion.constructor.name.should.be.equal('InvalidState')

    it 'should allow using "type" property', ->
      suggestion = suggestRAML ['resourceTypes', '- collection', 'type']
      suggestion.constructor.name.should.not.be.equal('InvalidState')

      suggestion = suggestRAML ['resourceTypes', '- collection', 'type', 'hello']
      suggestion.constructor.name.should.be.equal('InvalidState')

    it 'should suggest "protocols" key inside a resource type', ->
      suggestion = suggestRAML [ 'resourceTypes', 'someResourceTypeName', 'get' ]
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.key 'protocols'

  describe 'Responses', ->
    it 'should support arrays as keys', ->
      arraysAsKeysSuggestion = suggestRAML ['/foo', 'get', 'responses', '[200, 210]']
      suggestion = suggestRAML ['/foo', 'get', 'responses', '200']

      arraysAsKeysSuggestion.suggestions.should.include.keys (Object.keys suggestion.suggestions)

  describe 'Resources', ->
    it 'should offer "is" keyword as part of the suggestions', ->
      suggestion = suggestRAML ['/hello']
      {suggestions} = suggestion
      suggestions.should.include.keys 'is'

      suggestion = suggestRAML ['/hello', '/bye']
      {suggestions} = suggestion
      suggestions.should.include.keys 'is'

      suggestion = suggestRAML ['/hello/bye']
      {suggestions} = suggestion
      suggestions.should.include.keys 'is'


    it 'should not offer the "use" keyword as part of the suggestions', ->
      suggestion = suggestRAML ['/hello']
      {suggestions} = suggestion
      suggestions.should.not.include.keys 'use'

      suggestion = suggestRAML ['/hello', '/bye']
      {suggestions} = suggestion
      suggestions.should.not.include.keys 'use'

      suggestion = suggestRAML ['/hello/bye']
      {suggestions} = suggestion
      suggestions.should.not.include.keys 'use'

    it 'should display "is" suggestion as being scalar (in order to indent it on the same line)', ->
      suggestion = suggestRAML ['/hello', 'is']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello', '/bye', 'is']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello/bye', 'is']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

    it 'should offer "type" keyword as part of the suggestions', ->
      suggestion = suggestRAML ['/hello']
      {suggestions} = suggestion
      suggestions.should.include.keys 'type'

      suggestion = suggestRAML ['/hello', '/bye']
      {suggestions} = suggestion
      suggestions.should.include.keys 'type'

      suggestion = suggestRAML ['/hello/bye']
      {suggestions} = suggestion
      suggestions.should.include.keys 'type'


    it 'should display "type" suggestion as being scalar (in order to indent it on the same line)', ->
      suggestion = suggestRAML ['/hello', 'type']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello', '/bye', 'type']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello/bye', 'type']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

    it 'should allow to use "securedBy" to specify a securing policy for all the actions', ->
      suggestion = suggestRAML ['/hello', 'securedBy']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello', '/bye', 'securedBy']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello/bye', 'securedBy']
      suggestion.should.be.ok
      suggestion.isScalar.should.be.true

    it 'should suggest "baseUriParameters" and "uriParameters"', ->
      suggestion = suggestRAML ['/hello']
      suggestion.should.be.ok

      {suggestions} = suggestion

      suggestions.should.include.key 'uriParameters'
      suggestions.should.include.key 'baseUriParameters'

      suggestion = suggestRAML ['/hello', '/bye']
      suggestion.should.be.ok
      {suggestions} = suggestion

      suggestions.should.include.key 'uriParameters'
      suggestions.should.include.key 'baseUriParameters'

      suggestion = suggestRAML ['/hello/bye']
      suggestion.should.be.ok
      {suggestions} = suggestion

      suggestions.should.include.key 'uriParameters'
      suggestions.should.include.key 'baseUriParameters'

  describe 'Actions', ->
    it 'should allow to use "securedBy" to specify a securing policy', ->
      suggestion = suggestRAML ['/hello', 'get', 'securedBy']
      suggestion.should.be.ok
      suggestion.constructor.name.should.not.be.equal('InvalidState')

    it 'should suggest "protocols"', ->
      suggestion = suggestRAML [ '/resource', 'get' ]
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.key 'protocols'

  describe 'Security Schemes', ->
    it 'support "securitySchemes" keyword at the root level', ->
      suggestion = suggestRAML ['securitySchemes']
      suggestion.should.be.ok
      suggestion.constructor.name.should.not.be.equal('InvalidState')
      suggestion.suggestions.should.not.include.key 'get'

    it 'should include the "description" keyword', ->
      suggestion = suggestRAML ['securitySchemes', '- oauth_2_0']
      {suggestions} = suggestion
      suggestions.should.include.keys 'description'

    it 'should support "type" keyword', ->
      suggestion = suggestRAML ['securitySchemes', '- oauth_2_0']
      {suggestions} = suggestion
      suggestions.should.include.keys 'type'

    it.skip 'should support "type" suggestions', ->
      suggestion = suggestRAML ['securitySchemes', '- oauth_2_0', 'type']
      {suggestions} = suggestion
      suggestions.should.include.keys 'OAuth 1.0', 'OAuth 2.0', 'Basic Authentication',
        'Digest Authentication'

    it 'should support "settings" attribute', ->
      suggestion = suggestRAML ['securitySchemes', '- oauth_2_0', 'settings']
      {suggestions} = suggestion
      suggestions.should.include.keys 'requestTokenUri', 'authorizationUri', 'tokenCredentialsUri',
        'accessTokenUri', 'authorizationGrants', 'scopes'
      suggestion.should.have.property 'open'

    it 'should support "securedBy" as a root element', ->
      suggestion = suggestRAML ['securedBy']
      suggestion.should.be.ok
      suggestion.constructor.name.should.not.be.equal('InvalidState')

  describe 'Root', ->
    it 'should suggest "mediaType" and not "defaultMediaType"', ->
      suggestion = suggestRAML []
      suggestion.should.be.ok
      {suggestions} = suggestion

      suggestions.should.include.key 'mediaType'

      suggestions.should.not.include.key 'defaultMediaType'


    it 'should suggest "baseUriParameters" and not "uriParameters"', ->
      suggestion = suggestRAML []
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.key 'baseUriParameters'

      suggestions.should.not.include.key 'uriParameters'

    it 'should suggest "protocols"', ->
      suggestion = suggestRAML []
      suggestion.should.be.ok
      {suggestions} = suggestion

      suggestions.should.include.key 'protocols'

  describe 'Protocols', ->
    it.skip 'should suggest both HTTP and HTTPS inside a "protocols" key inside an action', ->
      suggestion = suggestRAML [ '/resource', 'get', 'protocols' ]
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.keys 'HTTP', 'HTTPS'

    it.skip 'should suggest both HTTP and HTTPS inside a "protocols" key in the root element', ->
      suggestion = suggestRAML [ 'protocols' ]
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.keys 'HTTP', 'HTTPS'

    it.skip 'should suggest both HTTP and HTTPS inside a "protocols" key in a trait', ->
      suggestion = suggestRAML [ 'traits', 'someTraitName', 'protocols' ]
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.keys 'HTTP', 'HTTPS'

    it.skip 'should suggest both HTTP and HTTPS inside a "protocols" key inside a resource type', ->
      suggestion = suggestRAML [ 'resourceTypes', 'someResourceTypeName', 'get', 'protocols' ]
      suggestion.should.be.ok
      {suggestions} = suggestion
      suggestions.should.include.keys 'HTTP', 'HTTPS'
