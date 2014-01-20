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

noopSuggestor = new EmptySuggestor

namedParameterSuggestor = new Suggestor(
  [
    new SuggestionItem('description', noopSuggestor, category: 'docs'),
    new SuggestionItem('displayName', noopSuggestor, category: 'docs'),
    new SuggestionItem('example',     noopSuggestor, category: 'docs'),
    new SuggestionItem('default',     noopSuggestor, category: 'parameters'),
    new SuggestionItem('enum',        noopSuggestor, category: 'parameters'),
    new SuggestionItem('maximum',     noopSuggestor, category: 'parameters'),
    new SuggestionItem('maxLength',   noopSuggestor, category: 'parameters'),
    new SuggestionItem('minimum',     noopSuggestor, category: 'parameters'),
    new SuggestionItem('minLength',   noopSuggestor, category: 'parameters'),
    new SuggestionItem('pattern',     noopSuggestor, category: 'parameters'),
    new SuggestionItem('required',    noopSuggestor, category: 'parameters'),
    new SuggestionItem('type',        noopSuggestor, category: 'parameters')
  ]
)

namedParameterGroupSuggestor = new EmptySuggestor (key) -> namedParameterSuggestor

responseBodyMimetypeSuggestor = new Suggestor(
  [
    new SuggestionItem('schema',  noopSuggestor, category: 'schemas'),
    new SuggestionItem('example', noopSuggestor, category: 'docs')
  ]
)

responseBodyGroupSuggestor = new Suggestor(
  [
    new SuggestionItem('application/json',                  responseBodyMimetypeSuggestor, category: 'body'),
    new SuggestionItem('application/x-www-form-urlencoded', responseBodyMimetypeSuggestor, category: 'body'),
    new SuggestionItem('application/xml',                   responseBodyMimetypeSuggestor, category: 'body'),
    new SuggestionItem('multipart/form-data',               responseBodyMimetypeSuggestor, category: 'body')
  ]
)

responseSuggestor = new Suggestor(
  [
    new SuggestionItem('body',        responseBodyGroupSuggestor, category: 'responses'),
    new SuggestionItem('description', noopSuggestor,              category: 'docs')
  ]
)

responseGroupSuggestor = new EmptySuggestor (key) -> responseSuggestor if /\d{3}/.test key
requestBodySuggestor   = new EmptySuggestor -> namedParameterGroupSuggestor

methodBodySuggestor = new Suggestor(
  [
    new SuggestionItem('application/json',                  noopSuggestor,        category: 'body'),
    new SuggestionItem('application/x-www-form-urlencoded', requestBodySuggestor, category: 'body'),
    new SuggestionItem('application/xml',                   noopSuggestor,        category: 'body'),
    new SuggestionItem('multipart/form-data',               requestBodySuggestor, category: 'body')
  ]
)

protocolsSuggestor = new Suggestor(
  [
    new SuggestionItem('HTTP',  noopSuggestor, { isText: true}),
    new SuggestionItem('HTTPS', noopSuggestor, { isText: true})
  ],
    null,
    { isList: true }
)

makeMethodSuggestor = ->
  new Suggestor(
    [
      new SuggestionItem('description',        noopSuggestor,                category: 'docs'),
      new SuggestionItem('body',               methodBodySuggestor,          category: 'body'),
      new SuggestionItem('protocols',          protocolsSuggestor,           category: 'root'),
      new SuggestionItem('baseUriParameters',  namedParameterGroupSuggestor, category: 'parameters'),
      new SuggestionItem('headers',            namedParameterGroupSuggestor, category: 'parameters'),
      new SuggestionItem('queryParameters',    namedParameterGroupSuggestor, category: 'parameters'),
      new SuggestionItem('responses',          responseGroupSuggestor,       category: 'responses'),
      new SuggestionItem('securedBy',          noopSuggestor,                category: 'security')
    ]
  )

makeMethodGroupSuggestor = (optional = false) ->
  methodSuggestor = new UnionSuggestor(
    [
      makeMethodSuggestor(),
      new Suggestor(
        [
          new SuggestionItem('is', noopSuggestor, category: 'traits and types')
        ]
      )
    ]
  )

  new Suggestor(
    new SuggestionItem(method, methodSuggestor, category: 'methods', canBeOptional: optional) for method in [
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
  )

resourceBasicSuggestor = new Suggestor(
  [
    new SuggestionItem('description', noopSuggestor, category: 'docs'),
    new SuggestionItem('displayName', noopSuggestor, category: 'docs'),
    new SuggestionItem('securedBy',   noopSuggestor, category: 'security'),
    new SuggestionItem('type',        noopSuggestor, category: 'traits and types'),
    new SuggestionItem('is',          noopSuggestor, category: 'traits and types')
  ]
)

resourceFallback = (key) -> resourceSuggestor if /^\//.test key

dynamicResource = new SuggestionItem('<resource>', resourceSuggestor, category: 'resources', dynamic: true)
resourceSuggestor = new UnionSuggestor(
  [
    resourceBasicSuggestor,
    makeMethodGroupSuggestor(),
    new Suggestor(
      [
        new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, category: 'parameters'),
        new SuggestionItem('uriParameters',     namedParameterGroupSuggestor, category: 'parameters'),
        dynamicResource
      ]
    )
  ],
  resourceFallback
)

traitAdditions = new Suggestor(
  [
    new SuggestionItem('displayName', noopSuggestor, category: 'docs'),
    new SuggestionItem('usage',       noopSuggestor, category: 'docs')
  ]
)

traitSuggestor = new UnionSuggestor(
  [
    traitAdditions,
    makeMethodSuggestor()
  ]
)

resourceTypeSuggestor = new UnionSuggestor(
  [
    resourceBasicSuggestor,
    makeMethodGroupSuggestor(true),
    new Suggestor(
      [
        new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor, category: 'parameters', canBeOptional: true),
        new SuggestionItem('uriParameters',     namedParameterGroupSuggestor, category: 'parameters', canBeOptional: true)
        new SuggestionItem('usage',             noopSuggestor,                category: 'docs')
      ]
    )
  ]
)

securitySchemesSettingSuggestor = new Suggestor(
  [
    new SuggestionItem('accessTokenUri',      noopSuggestor, category: 'security'),
    new SuggestionItem('authorizationGrants', noopSuggestor, category: 'security'),
    new SuggestionItem('authorizationUri',    noopSuggestor, category: 'security'),
    new SuggestionItem('requestTokenUri',     noopSuggestor, category: 'security'),
    new SuggestionItem('scopes',              noopSuggestor, category: 'security'),
    new SuggestionItem('tokenCredentialsUri', noopSuggestor, category: 'security')
  ]
)

securitySchemeTypeSuggestor = new Suggestor(
  [
    new SuggestionItem('OAuth 1.0',             noopSuggestor, category: 'security'),
    new SuggestionItem('OAuth 2.0',             noopSuggestor, category: 'security'),
    new SuggestionItem('Basic Authentication',  noopSuggestor, category: 'security'),
    new SuggestionItem('Digest Authentication', noopSuggestor, category: 'security')
  ]
)

describedBySuggestor = new Suggestor(
  [
    new SuggestionItem('headers',         namedParameterGroupSuggestor, category: 'parameters'),
    new SuggestionItem('queryParameters', namedParameterGroupSuggestor, category: 'parameters'),
    new SuggestionItem('responses',       responseGroupSuggestor,       category: 'responses')
  ]
)

securitySchemesSuggestor = new Suggestor(
  [
    new SuggestionItem('description', noopSuggestor,                   category: 'docs'),
    new SuggestionItem('describedBy', describedBySuggestor,            category: 'security'),
    new SuggestionItem('type',        securitySchemeTypeSuggestor,     category: 'security'),
    new SuggestionItem('settings',    securitySchemesSettingSuggestor, category: 'security')
  ]
)

traitGroupSuggestor           = new EmptySuggestor -> traitSuggestor
resourceTypeGroupSuggestor    = new EmptySuggestor -> resourceTypeSuggestor
securitySchemesGroupSuggestor = new EmptySuggestor -> securitySchemesSuggestor

rootDocumentationSuggestor = new Suggestor(
  [
    new SuggestionItem('content', noopSuggestor, category: 'docs'),
    new SuggestionItem('title',   noopSuggestor, category: 'docs')
  ],
    null,
    { isList: true }
)

rootSuggestor = new Suggestor(
  [
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor,  category: 'parameters'),
    new SuggestionItem('baseUri',           noopSuggestor,                 category: 'root'),
    new SuggestionItem('mediaType',         noopSuggestor,                 category: 'root'),
    new SuggestionItem('protocols',         protocolsSuggestor,            category: 'root'),
    new SuggestionItem('title',             noopSuggestor,                 category: 'root'),
    new SuggestionItem('version',           noopSuggestor,                 category: 'root')
    new SuggestionItem('documentation',     rootDocumentationSuggestor,    category: 'docs'),
    new SuggestionItem('schemas',           noopSuggestor,                 category: 'schemas'),
    new SuggestionItem('securedBy',         noopSuggestor,                 category: 'security'),
    new SuggestionItem('securitySchemes',   securitySchemesGroupSuggestor, category: 'security'),
    new SuggestionItem('resourceTypes',     resourceTypeGroupSuggestor,    category: 'traits and types'),
    new SuggestionItem('traits',            traitGroupSuggestor,           category: 'traits and types'),
    dynamicResource
  ],
  resourceFallback
)

suggestorForPath = (path) ->
  path      = [] unless path
  suggestor = rootSuggestor

  while suggestor and path.length
    suggestor = suggestor.suggestorFor path.shift()

  suggestor

@suggestRAML = (path) ->
  suggestor = (suggestorForPath path) or noopSuggestor
  return {
    suggestions: suggestor.suggestions(),
    metadata: suggestor.metadata
  }

if window?
  window.suggestRAML = @suggestRAML
