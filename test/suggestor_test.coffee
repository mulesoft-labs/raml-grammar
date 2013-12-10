{suggestRAML} = require '../src/suggestor.coffee'
should = (require '../node_modules/chai/index').should()

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

supportedMimeTypes = [ 'application/json', 'application/xml', 'application/x-www-form-urlencoded', 'multipart/form-data' ]

describe 'suggestRAML',  ->
  it 'offers expected suggestions for empty arrays, null, and undefined', ->
    for root in [[], null, undefined]
      {suggestions} = suggestRAML []
      suggestions.should.include.keys 'title', 'version', 'schemas', 'baseUri', 'baseUriParameters', 'mediaType', 'documentation', 'traits', 'resourceTypes', 'securitySchemes', 'securedBy', 'protocols'

  it 'handles an string value nodes', ->
    result = suggestRAML ['title']
    result.suggestions.should.be.empty
    result.isScalar.should.be.true

###
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
###

describe 'Security Schemes', ->
  it 'offers expected suggestions', ->
    suggestion = suggestRAML ['securitySchemes', 'oauth_2_0']
    {suggestions} = suggestion
    suggestions.should.include.keys 'description', 'type', 'settings'

  it 'supports "type" suggestions', ->
    suggestion = suggestRAML ['securitySchemes', 'oauth_2_0', 'type']
    {suggestions} = suggestion
    suggestions.should.include.keys 'OAuth 1.0', 'OAuth 2.0', 'Basic Authentication',
      'Digest Authentication'

  it 'suggests keys for the "settings" attribute', ->
    suggestion = suggestRAML ['securitySchemes', 'oauth_2_0', 'settings']
    {suggestions} = suggestion
    suggestions.should.include.keys 'requestTokenUri', 'authorizationUri', 'tokenCredentialsUri',
      'accessTokenUri', 'authorizationGrants', 'scopes'

describe 'Resource Types', ->
  it 'returns no suggestions in the array', ->
    {suggestions} = suggestRAML ['resourceTypes']
    suggestions.should.be.empty

  it 'contains all the properties found in a resource suggestion', ->
    {suggestions: resourceTypeSuggestion} = suggestRAML ['resourceTypes', 'collection']
    {suggestions: resourceSuggestions} = suggestRAML ['/hello']

    resourceTypeSuggestion.should.include.keys (Object.keys resourceSuggestions)

  it 'also includes the usage property', ->
    {suggestions} = suggestRAML ['resourceTypes', 'collection']
    suggestions.should.include.key 'usage'

  it 'supports nesting inside properties', ->
    {suggestions} = suggestRAML ['resourceTypes', 'collection', 'get']
    {suggestions: methodSuggestions} = suggestRAML ['/hello', 'get']
    suggestions.should.include.keys (Object.keys methodSuggestions)

    {suggestions} = suggestRAML ['resourceTypes', 'collection', 'get', 'responses', '200']
    suggestions.should.include.keys 'description'

  it 'does not allow nesting of resources', ->
    {suggestions} = suggestRAML ['resourceTypes', 'collection', '/hello']
    suggestions.should.be.empty

  it 'suggests the same properties as optional properties', ->
    {suggestions: suggestions1} = suggestRAML ['resourceTypes', 'resourceType1', 'get?']
    {suggestions: suggestions2} = suggestRAML ['resourceTypes', 'resourceType2', 'get' ]
    suggestions1.should.be.deep.equal(suggestions2)

describe 'Traits', ->
  it 'returns no suggestions in the array', ->
    {suggestions} = suggestRAML ['traits']
    suggestions.should.be.empty

  it 'contains all the properties found in a method suggestion', ->
    {suggestions: traitSuggestions} = suggestRAML ['traits', 'traitA']
    {suggestions: methodSuggestions} = suggestRAML ['/', 'get']

    traitSuggestions.should.include.keys(Object.keys(methodSuggestions))

  it 'also contains "usage" and "displayName" properties', ->
    {suggestions} = suggestRAML ['traits', 'traitA']
    suggestions.should.include.key 'usage'
    suggestions.should.include.key 'displayName'

  it 'allows for nested suggestions inside its properties', ->
    {suggestions} = suggestRAML ['traits', 'traitA', 'responses']
    suggestions.should.be.empty

    {suggestions} = suggestRAML ['traits', 'traitA', 'responses', '200']
    suggestions.should.include.keys 'description'

describe 'Resources', ->
  it 'offers expected suggestions', ->
    for path in [
      ['/hello'],
      ['/hello', '/bye'],
      ['/hello/bye'],
      ['/hello', '/{param}', '/bye']
    ]
      {suggestions} = suggestRAML path
      suggestions.should.include.key 'baseUriParameters'
      suggestions.should.include.key 'description'
      suggestions.should.include.key 'is'
      suggestions.should.include.key 'type'
      suggestions.should.include.key 'securedBy'
      suggestions.should.include.key 'uriParameters'
      suggestions.should.include.keys(supportedHttpMethods)

      suggestions.should.not.include.key 'usage'

describe 'Methods', ->
  it 'offers expected suggestions', ->
    {suggestions} = suggestRAML ['/hello', 'get']

    suggestions.should.include.key 'protocols'
    suggestions.should.include.key 'is'
    suggestions.should.include.key 'body'
    suggestions.should.include.key 'headers'
    suggestions.should.include.key 'securedBy'
    suggestions.should.include.key 'responses'
    suggestions.should.include.key 'queryParameters'

    suggestions.should.not.include.key 'usage'

  describe 'body', ->
    it 'contains common mime-types as sublevel suggestions (RT-81)', ->
      {suggestions} = suggestRAML ['/hello', 'get', 'body']

      suggestions.should.include.keys supportedMimeTypes

describe 'Named Parameters', ->
  expectedKeys = ['displayName', 'description', 'type', 'enum', 'pattern', 'minLength', 'maxLength', 'maximum', 'minimum', 'required', 'default', 'example']

  it 'is supported within the path resource/method/body/form-mime-type/formParameters', ->
    {suggestions} = suggestRAML ['/resource', 'get', 'body', 'multipart/form-data', 'formParameters', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is not supported within the path resource/method/body/non-form-mime-type/formParameters', ->
    {suggestions} = suggestRAML ['/resource', 'get', 'body', 'application/json']
    suggestions.should.not.include.key 'formParameters'

  it 'is supported within the path resource/method/queryParameters', ->
    {suggestions} = suggestRAML ['/resource', 'get', 'queryParameters', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is supported within the path resource/method/headers', ->
    {suggestions} = suggestRAML ['/resource', 'get', 'headers', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is supported within the path resource/uriParameters', ->
    {suggestions} = suggestRAML ['/resource', 'uriParameters', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is supported within the path root/baseUriParameters', ->
    {suggestions} = suggestRAML ['baseUriParameters', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is supported within the path root/resource/baseUriParameters', ->
    {suggestions} = suggestRAML ['/resource', 'baseUriParameters', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is supported within the path trait/method/body/form-mime-type/formParameters', ->
    {suggestions} = suggestRAML ['traits', 'someTraitName', 'body', 'multipart/form-data', 'formParameters', 'someName']
    suggestions.should.include.keys expectedKeys

  it 'is supported within the path resource-type/method/body/form-mime-type/formParameters', ->
    {suggestions} = suggestRAML ['resourceTypes', 'someResourceTypeName', 'post', 'body', 'multipart/form-data', 'formParameters', 'someName']
    suggestions.should.include.keys expectedKeys

describe 'Responses', ->
  it 'offers expected suggestions', ->
    {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses']
    suggestions.should.be.empty

    {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses', '200']
    suggestions.should.include.keys 'body', 'description'

    {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses', '200', 'body']
    suggestions.should.include.keys supportedMimeTypes

    {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses', '200', 'body', 'application/json']
    suggestions.should.include.keys 'schema', 'example'

  it 'supports arrays as keys', ->
    arraysAsKeysSuggestion = suggestRAML ['/foo', 'get', 'responses', '[200, 210]']
    suggestion = suggestRAML ['/foo', 'get', 'responses', '200']

    arraysAsKeysSuggestion.suggestions.should.include.keys (Object.keys suggestion.suggestions)

describe 'Protocols', ->
  it 'suggests both HTTP and HTTPS inside a "protocols" key inside an action', ->
    {suggestions} = suggestRAML [ '/resource', 'get', 'protocols' ]
    suggestions.should.include.keys 'HTTP', 'HTTPS'

  it 'suggests both HTTP and HTTPS inside a "protocols" key in the root element', ->
    {suggestions} = suggestRAML [ 'protocols' ]
    suggestions.should.include.keys 'HTTP', 'HTTPS'

  it 'suggests both HTTP and HTTPS inside a "protocols" key in a trait', ->
    {suggestions} = suggestRAML [ 'traits', 'someTraitName', 'protocols' ]
    suggestions.should.include.keys 'HTTP', 'HTTPS'

  it 'suggests both HTTP and HTTPS inside a "protocols" key inside a resource type', ->
    {suggestions} = suggestRAML [ 'resourceTypes', 'someResourceTypeName', 'get', 'protocols' ]
    suggestions.should.include.keys 'HTTP', 'HTTPS'

describe 'Paths with optional methods', ->
  it 'do not generate suggestions inside a /resource', ->
    for path in [
      ['/hello', 'get?'],
      ['/hello', '/bye', 'get?'],
      ['/hello/bye', 'get?']
    ]

      {suggestions} = suggestRAML path
      suggestions.should.be.empty
