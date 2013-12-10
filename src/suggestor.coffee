class Suggestor
  constructor: (@suggestors, options = {}) ->
    {@fallback, @metadata, @isScalar} = options

    @isScalar ?= false
    @metadata ?= {}
    @fallback ?= ->

  suggestorFor: (key) ->
    suggestors = @suggestors.filter (suggestor) ->
      suggestor[0] == key ||
      suggestor[0] + '?' == key && suggestor[1].metadata.canBeOptional

    if suggestors.length > 0
      suggestors[0][1]
    else
      @fallback(key)

  suggestions: ->
    suggestions = {}
    for suggestor in @suggestors
      suggestions[suggestor[0]] = {
        metadata: suggestor[1].metadata
      }

    suggestions

class EmptySuggestor extends Suggestor
  constructor:  (options) ->
    super [], options

  suggestorFor: (key) -> @

class UnionSuggestor extends Suggestor
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

noopSuggestor    = new EmptySuggestor
scalarSuggestor  = new EmptySuggestor isScalar: true
resourceFallback = (key) -> resourceSuggestor if /^\//.test key

namedParameterSuggestor = new Suggestor(
  [
    ['default',     scalarSuggestor],
    ['description', scalarSuggestor],
    ['displayName', scalarSuggestor],
    ['enum',        scalarSuggestor],
    ['example',     scalarSuggestor],
    ['maximum',     scalarSuggestor],
    ['maxLength',   scalarSuggestor],
    ['minimum',     scalarSuggestor],
    ['minLength',   scalarSuggestor],
    ['pattern',     scalarSuggestor],
    ['required',    scalarSuggestor],
    ['type',        scalarSuggestor]
  ]
)

namedParameterGroupSuggestor = new Suggestor [], fallback: (key) -> namedParameterSuggestor

responseBodyMimetypeSuggestor = new Suggestor(
  [
    ['schema',    noopSuggestor],
    ['example', noopSuggestor]
  ]
)

responseBodyGroupSuggestor = new Suggestor(
  [
    ['application/json',                  responseBodyMimetypeSuggestor],
    ['application/x-www-form-urlencoded', responseBodyMimetypeSuggestor],
    ['application/xml',                   responseBodyMimetypeSuggestor],
    ['multipart/form-data',               responseBodyMimetypeSuggestor]
  ]
)

responseSuggestor = new Suggestor(
  [
    ['body',        responseBodyGroupSuggestor],
    ['description', scalarSuggestor],
  ]
)

responseGroupSuggestor = new Suggestor [], fallback: (key) -> responseSuggestor if /\d{3}/.test key
requestBodySuggestor   = new Suggestor [], fallback: -> namedParameterGroupSuggestor

methodBodySuggestor = new Suggestor(
  [
    ['application/json',                  noopSuggestor],
    ['application/x-www-form-urlencoded', requestBodySuggestor],
    ['application/xml',                   noopSuggestor],
    ['multipart/form-data',               requestBodySuggestor]
  ]
)

protocolsSuggestor = new Suggestor(
  [
    ['HTTP',  noopSuggestor],
    ['HTTPS', noopSuggestor]
  ]
)

makeMethodSuggestor = (optional = false) ->
  new Suggestor(
    [
      ['body',            methodBodySuggestor],
      ['headers',         namedParameterGroupSuggestor],
      ['is',              noopSuggestor],
      ['protocols',       protocolsSuggestor],
      ['queryParameters', namedParameterGroupSuggestor],
      ['responses',       responseGroupSuggestor],
      ['securedBy',       noopSuggestor]
    ],
    {
      metadata: { category: 'methods', canBeOptional: optional }
    }
  )

makeMethodGroupSuggestor = (optional = false) ->
  methodSuggestor = makeMethodSuggestor(optional)

  new Suggestor(
    [method, methodSuggestor] for method in ['get', 'post', 'put', 'delete', 'head', 'patch', 'trace', 'connect', 'options']
  )

resourceBasicSuggestor = new Suggestor(
  [
    ['baseUriParameters', namedParameterGroupSuggestor],
    ['description',       scalarSuggestor],
    ['displayName',       scalarSuggestor],
    ['is',                scalarSuggestor],
    ['securedBy',         scalarSuggestor],
    ['type',              scalarSuggestor],
    ['uriParameters',     namedParameterGroupSuggestor]
  ]
)

resourceSuggestor = new UnionSuggestor(
  [
    resourceBasicSuggestor,
    makeMethodGroupSuggestor()
  ],
  {
   fallback: resourceFallback,
   metadata: { id: 'resource' }
  }
)

traitAdditions = new Suggestor(
  [
    ['displayName', noopSuggestor],
    ['usage',       noopSuggestor]
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
    new Suggestor (
      [
        ['usage', noopSuggestor]
      ]
    )
  ]
)

securitySchemesSettingSuggestor = new Suggestor(
  [
    ['requestTokenUri',        noopSuggestor],
    ['authorizationUri',       noopSuggestor],
    ['tokenCredentialsUri',    noopSuggestor],
    ['accessTokenUri',         noopSuggestor],
    ['scopes',                 noopSuggestor],
    ['authorizationGrants',    noopSuggestor]
  ]
)

securitySchemeTypeSuggestor = new Suggestor(
  [
    ['OAuth 1.0',              noopSuggestor],
    ['OAuth 2.0',              noopSuggestor],
    ['Basic Authentication',   noopSuggestor],
    ['Digest Authentication',  noopSuggestor]
  ]
)

securitySchemesSuggestor = new Suggestor(
  [
    ['description', noopSuggestor],
    ['type',        securitySchemeTypeSuggestor],
    ['settings',    securitySchemesSettingSuggestor]
  ]
)

traitGroupSuggestor           = new Suggestor [], fallback: -> traitSuggestor
resourceTypeGroupSuggestor    = new Suggestor [], fallback: -> resourceTypeSuggestor
securitySchemesGroupSuggestor = new Suggestor [], fallback: -> securitySchemesSuggestor

rootSuggestor = new Suggestor(
  [
    ['baseUri',           scalarSuggestor],
    ['baseUriParameters', namedParameterGroupSuggestor],
    ['documentation',     noopSuggestor],
    ['mediaType',         noopSuggestor],
    ['protocols',         protocolsSuggestor],
    ['resourceTypes',     resourceTypeGroupSuggestor],
    ['schemas',           noopSuggestor],
    ['securedBy',         noopSuggestor],
    ['securitySchemes',   securitySchemesGroupSuggestor],
    ['title',             scalarSuggestor],
    ['traits',            traitGroupSuggestor],
    ['version',           scalarSuggestor]
  ],
  {
    fallback: resourceFallback
  }
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
    suggestions: suggestor.suggestions()
    metadata:    suggestor.metadata
    isScalar:    suggestor.isScalar
  }

window.suggestRAML = @suggestRAML if typeof window != 'undefined'

