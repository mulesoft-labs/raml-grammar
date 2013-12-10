{suggestRAML} = require '../src/suggestor.coffee'
should = (require '../node_modules/chai/index').should()
{typ3: type} = require '../src/utils.coffee'
type =
  of: type
supportedHttpMethods = [
  # RFC2616
  'options',
  'get',
  'head',
  'post',
  'put',
  'delete',
  'trace',
  'connect',
  # RFC5789
  'patch'
]

describe 'suggest',  ->
  it 'should handle root node as an empty array, null and undefined', ->
    for root in [[], null, undefined]
      {suggestions} = suggestRAML []
      suggestions.should.include.keys 'title', 'version', 'schemas', 'baseUri', 'baseUriParameters', 'mediaType', 'documentation', 'traits', 'resourceTypes', 'securitySchemes', 'securedBy', 'protocols'

  it 'should handle an string value nodes', ->
    {suggestions} = suggestRAML ['title']
    suggestions.should.be.empty

  it 'should work with resources nodes', ->
    {suggestions} = suggestRAML ['/hello', '/this', '/{is}', '/a', '/resource']
    console.log(suggestions)
    suggestions.should.include.keys(supportedHttpMethods)

  it 'should work with complex nested scenarios', ->
    {suggestions} = suggestRAML ['/tags', '/search', 'get', 'headers', 'asd']

    suggestions.should.include.keys('displayName', 'description',
      'type', 'enum', 'pattern', 'minLength', 'maxLength', 'maximum', 'minimum', 'required',
      'default', 'example')

  it 'should be weakly equal when called multiple times', ->
    suggestion = suggestRAML ['/hello', '/this', '/{is}', '/a', '/resource']
    suggestion2 = suggestRAML ['/hello', '/this', '/{is}', '/a', '/resource']

    JSON.stringify(suggestion).should.be.equal(JSON.stringify(suggestion2))

  it 'should work with numerical fields', ->
    {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses']
    suggestions.should.be.empty

    {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses', '200']
    suggestions.should.include.keys 'body', 'description'

  it 'should tell me whether a node is an scalar or not', ->
    suggestion = suggestRAML ['/tags']
    suggestion.isScalar.should.be.equal false

    suggestion = suggestRAML ['title']
    suggestion.isScalar.should.be.equal true

    suggestion = suggestRAML ['/tags', 'displayName']
    suggestion.isScalar.should.be.equal true

  describe 'body', ->
    it 'should contain application/json and application/xml as sublevel suggestions (RT-81)', ->
      {suggestions} = suggestRAML ['/hello', 'get', 'body']
      (Object.keys suggestions).should.include 'application/json', 'application/xml'

describe 'Methods', ->
  describe 'patch', ->
    it 'should be written correctly', ->
      {suggestions} = suggestRAML ['/hello']
      suggestions.should.include.key 'patch'


describe 'Metadata', ->
  describe 'Category assignment', ->
    it 'should be "actions" for supported HTTP methods', ->
      suggestion = suggestRAML ['/pet']
      suggestion.should.have.property('suggestions')
      suggestions = suggestion.suggestions
      suggestions.should.have.property(action) for action in supportedHttpMethods

      for methodName in supportedHttpMethods
        method = suggestions[methodName]
        method.should.have.property('metadata')
        {metadata: {category}} = method
        category.should.be.equal('methods')

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

describe '0.8', ->
  describe 'Traits', ->
    it 'should support traits keyword', ->
      {suggestions} = suggestRAML ['traits']
      (Object.keys suggestions).length.should.be.equal(0)

    it 'should support a particular trait definition', ->
      suggestion = suggestRAML ['traits', '- traitA']
      suggestion.should.not.have.property('open')

    it 'should include the name property', ->
      {suggestions} = suggestRAML ['traits', '- traitA']
      (Object.keys suggestions).should.include 'displayName'

    it 'should contain all the properties found in methods', ->
      suggestion = suggestRAML ['traits', '- traitA']
      {suggestions} = suggestion
      {suggestions: getMethodSuggestions} = suggestRAML ['/hello', 'get']
      suggestionsCopy = JSON.parse(JSON.stringify(getMethodSuggestions))
      delete suggestionsCopy.is
      suggestions.should.include.keys (Object.keys suggestionsCopy)

    it 'should contain "usage" property', ->
      {suggestions} = suggestRAML ['traits', '- traitA']
      suggestions.should.include.key 'usage'

    it 'should support nesting inside properties', ->
      {suggestions} = suggestRAML ['traits', 'traitA', 'responses']
      (Object.keys suggestions).length.should.be.equal(0)

      {suggestions} = suggestRAML ['traits', 'traitA', 'responses', '200']
      suggestions.should.include.keys 'description'

    it 'should not offer "provides" or "requires" keywords', ->
      {suggestions} = suggestRAML ['traits', '- traitA']
      suggestions.should.not.include.keys 'provides', 'requires'

  describe 'Form Parameters', ->
    expectedKeys = ['displayName', 'description', 'type', 'enum', 'pattern', 'minLength', 'maxLength', 'maximum', 'minimum', 'required', 'default', 'example']
    it 'should support namedParameters properties in a formParameter in a resource', ->
      {suggestions} = suggestRAML ['/resource', 'get', 'body', 'multipart/form-data', 'formParameters', 'someName']
      suggestions.should.include.keys expectedKeys

    it 'should support namedParameters properties in a formParameter in a trait', ->
      {suggestions} = suggestRAML ['traits', 'someTraitName', 'body', 'multipart/form-data', 'formParameters', 'someName']
      suggestions.should.include.keys expectedKeys

    it 'should support namedParameters properties in a formParameter in a resource type', ->
      {suggestions} = suggestRAML ['resourceTypes', 'someResourceTypeName', 'post', 'body', 'multipart/form-data', 'formParameters', 'someName']
      suggestions.should.include.keys expectedKeys

  describe 'Resource Types', ->
    it 'should support resourceTypes keyword', ->
      {suggestions} = suggestRAML ['resourceTypes']
      suggestions.should.be.empty

    it 'should include displayName, description, type and usage properties', ->
      {suggestions} = suggestRAML ['resourceTypes', 'collection']
      suggestions.should.include.keys 'displayName',  'description',  'type',  'usage'

    it 'should contain all the properties found in a resource', ->
      {suggestions} = suggestRAML ['resourceTypes', 'collection']
      {suggestions: resourceSuggestions} = suggestRAML ['/hello']

      suggestions.should.include.keys (Object.keys resourceSuggestions)

    it 'should support nesting inside properties', ->
      {suggestions} = suggestRAML ['resourceTypes', 'collection', 'get']
      {suggestions: getMethodSuggestions} = suggestRAML ['/hello', 'get']
      suggestions.should.include.keys (Object.keys getMethodSuggestions)

      {suggestions} = suggestRAML ['resourceTypes', 'collection', 'get', 'responses', '200']
      suggestions.should.include.keys 'description'

    it 'should not allow nesting of resources', ->
      {suggestions} = suggestRAML ['resourceTypes', 'collection', '/hello']
      suggestions.should.be.empty

    it 'should suggest "protocols" key inside a resource type', ->
      {suggestions} = suggestRAML ['resourceTypes', 'someResourceTypeName', 'get']
      suggestions.should.include.key 'protocols'

    it 'should suggest the same properties as for optional properties', ->
      {suggestions: suggestions1} = suggestRAML ['resourceTypes', 'resourceType1', 'get?']
      {suggestions: suggestions2} = suggestRAML ['resourceTypes', 'resourceType2', 'get' ]
      suggestions1.should.be.deep.equal(suggestions2)

  describe 'Responses', ->
    it 'should support arrays as keys', ->
      arraysAsKeysSuggestion = suggestRAML ['/foo', 'get', 'responses', '[200, 210]']
      suggestion = suggestRAML ['/foo', 'get', 'responses', '200']

      arraysAsKeysSuggestion.suggestions.should.include.keys (Object.keys suggestion.suggestions)

  describe 'Resources', ->
    it 'should offer expected suggestions', ->
      for path in [
        ['/hello'],
        ['/hello', '/bye'],
        ['/hello/bye']
      ]
        {suggestions} = suggestRAML path
        suggestions.should.include.key 'baseUriParameters'
        suggestions.should.include.key 'description'
        suggestions.should.include.key 'is'
        suggestions.should.include.key 'type'
        suggestions.should.include.key 'uriParameters'

    it 'should not offer the "use" keyword as part of the suggestions', ->
      for path in [
        ['/hello'],
        ['/hello', '/bye'],
        ['/hello/bye']
      ]
        {suggestions} = suggestRAML path
        suggestions.should.not.include.key 'use'

    it 'should display "is" suggestion as being scalar (in order to indent it on the same line)', ->
      suggestion = suggestRAML ['/hello', 'is']
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello', '/bye', 'is']
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello/bye', 'is']
      suggestion.isScalar.should.be.true

    it 'should display "type" suggestion as being scalar (in order to indent it on the same line)', ->
      suggestion = suggestRAML ['/hello', 'type']
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello', '/bye', 'type']
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello/bye', 'type']
      suggestion.isScalar.should.be.true

    it 'should allow to use "securedBy" to specify a securing policy for all the actions', ->
      suggestion = suggestRAML ['/hello', 'securedBy']
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello', '/bye', 'securedBy']
      suggestion.isScalar.should.be.true

      suggestion = suggestRAML ['/hello/bye', 'securedBy']
      suggestion.isScalar.should.be.true

    it 'should not suggest "usage" property', ->
      {suggestions} = suggestRAML ['/hello']
      suggestions.should.not.include.key 'usage'

      {suggestions} = suggestRAML ['/hello', '/bye']
      suggestions.should.not.include.key 'usage'

      {suggestions} = suggestRAML ['/hello/bye']
      suggestions.should.not.include.key 'usage'

    it 'should suggest "example" inside and "uriParameters"', ->
      {suggestions} = suggestRAML ['/hello/bye', 'uriParameters', 'myParameter']
      suggestions.should.include.key 'example'

    it 'should suggest "example" inside and "baseUriParameters"', ->
      {suggestions} = suggestRAML ['/hello/bye', 'baseUriParameters', 'myParameter']
      suggestions.should.include.key 'example'

  describe 'Actions', ->
    it 'should allow to use "securedBy" to specify a securing policy', ->
      suggestion = suggestRAML ['/hello', 'get', 'securedBy']
      suggestion.constructor.name.should.not.be.equal('InvalidState')

    it 'should suggest "protocols"', ->
      {suggestions} = suggestRAML [ '/resource', 'get' ]
      suggestions.should.include.key 'protocols'

    it 'should suggest "is" inside an action', ->
      {suggestions} = suggestRAML [ '/resource', 'get' ]
      suggestions.should.include.key 'is'

    it 'should not suggest "usage" property', ->
      {suggestions} = suggestRAML ['/resource', 'get']
      suggestions.should.not.include.key 'usage'

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

    it 'should support "securedBy" as a root element', ->
      suggestion = suggestRAML ['securedBy']
      suggestion.should.be.ok
      suggestion.constructor.name.should.not.be.equal('InvalidState')

  describe 'Root', ->
    it 'should suggest "mediaType" and not "defaultMediaType"', ->
      {suggestions} = suggestRAML []
      suggestions.should.include.key 'mediaType'
      suggestions.should.not.include.key 'defaultMediaType'

    it 'should suggest "baseUriParameters" and not "uriParameters"', ->
      {suggestions} = suggestRAML []
      suggestions.should.include.key 'baseUriParameters'
      suggestions.should.not.include.key 'uriParameters'

    it 'should suggest "protocols"', ->
      {suggestions} = suggestRAML []
      suggestions.should.include.key 'protocols'

  describe 'Protocols', ->
    it 'should suggest both HTTP and HTTPS inside a "protocols" key inside an action', ->
      {suggestions} = suggestRAML [ '/resource', 'get', 'protocols' ]
      suggestions.should.include.keys 'HTTP', 'HTTPS'

    it 'should suggest both HTTP and HTTPS inside a "protocols" key in the root element', ->
      {suggestions} = suggestRAML [ 'protocols' ]
      suggestions.should.include.keys 'HTTP', 'HTTPS'

    it 'should suggest both HTTP and HTTPS inside a "protocols" key in a trait', ->
      {suggestions} = suggestRAML [ 'traits', 'someTraitName', 'protocols' ]
      suggestions.should.include.keys 'HTTP', 'HTTPS'

    it 'should suggest both HTTP and HTTPS inside a "protocols" key inside a resource type', ->
      {suggestions} = suggestRAML [ 'resourceTypes', 'someResourceTypeName', 'get', 'protocols' ]
      suggestions.should.include.keys 'HTTP', 'HTTPS'

describe 'Optional elements (get?, post?...)', ->
  it 'should not display them as options', ->
    {suggestions} = suggestRAML ['/resource']
    suggestions.should.not.include.keys ((method+'?') for method in supportedHttpMethods)

    {suggestions} = suggestRAML ['/resource', '/nested']
    suggestions.should.not.include.keys ((method+'?') for method in supportedHttpMethods)

    {suggestions} = suggestRAML ['/resource/merged']
    suggestions.should.not.include.keys ((method+'?') for method in supportedHttpMethods)

  it 'should not display suggestions for non-optional properties', ->
    # properties with question mark at the end under resource
    # are treated as a nested resources so we expect engine to
    # suggest HTTP methods for instance
    {suggestions} = suggestRAML [ '/hello', 'get?' ]
    suggestions.should.be.empty
