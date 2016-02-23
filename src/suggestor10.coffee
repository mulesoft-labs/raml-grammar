{EmptySuggestor} = require './suggestorXX'
{SuggestionItem} = require './suggestorXX'
{Suggestor}      = require './suggestorXX'
{UnionSuggestor} = require './suggestorXX'

{noopSuggestor}  = require './suggestorXX'

# ---

xmlSuggestor = new Suggestor(
  [
    new SuggestionItem('attribute', noopSuggestor, category: 'docs'),
    new SuggestionItem('name',      noopSuggestor, category: 'docs'),
    new SuggestionItem('namespace', noopSuggestor, category: 'docs'),
    new SuggestionItem('prefix',    noopSuggestor, category: 'docs'),
    new SuggestionItem('wrapped',   noopSuggestor, category: 'docs')
  ]
)

namedParameterSuggestor = new Suggestor(
  [
    new SuggestionItem('description',          noopSuggestor, category: 'docs'),
    new SuggestionItem('displayName',          noopSuggestor, category: 'docs'),
    new SuggestionItem('example',              noopSuggestor, category: 'docs'),
    new SuggestionItem('examples',             noopSuggestor, category: 'docs'),

    new SuggestionItem('additionalProperties', noopSuggestor, category: 'parameters'),
    new SuggestionItem('default',              noopSuggestor, category: 'parameters'),
    new SuggestionItem('discriminator',        noopSuggestor, category: 'parameters'),
    new SuggestionItem('discriminatorValue',   noopSuggestor, category: 'parameters'),
    new SuggestionItem('enum',                 noopSuggestor, category: 'parameters'),
    new SuggestionItem('facets',               noopSuggestor, category: 'parameters'),
    new SuggestionItem('fileTypes',            noopSuggestor, category: 'parameters'),
    new SuggestionItem('format',               noopSuggestor, category: 'parameters'),
    new SuggestionItem('items',                noopSuggestor, category: 'parameters'),
    new SuggestionItem('maximum',              noopSuggestor, category: 'parameters'),
    new SuggestionItem('maxItems',             noopSuggestor, category: 'parameters'),
    new SuggestionItem('maxLength',            noopSuggestor, category: 'parameters'),
    new SuggestionItem('maxProperties',        noopSuggestor, category: 'parameters'),
    new SuggestionItem('minimum',              noopSuggestor, category: 'parameters'),
    new SuggestionItem('minItems',             noopSuggestor, category: 'parameters'),
    new SuggestionItem('minLength',            noopSuggestor, category: 'parameters'),
    new SuggestionItem('minProperties',        noopSuggestor, category: 'parameters'),
    new SuggestionItem('multipleOf',           noopSuggestor, category: 'parameters'),
    new SuggestionItem('pattern',              noopSuggestor, category: 'parameters'),
    new SuggestionItem('properties',           noopSuggestor, category: 'parameters'),
    new SuggestionItem('required',             noopSuggestor, category: 'parameters'),
    new SuggestionItem('schema',               noopSuggestor, category: 'parameters'),
    new SuggestionItem('type',                 noopSuggestor, category: 'parameters'),
    new SuggestionItem('uniqueItems',          noopSuggestor, category: 'parameters'),
    new SuggestionItem('xml',                  xmlSuggestor,  category: 'parameters')
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

documentationItemSuggestor = new Suggestor(
  [
    new SuggestionItem('content', noopSuggestor, category: 'docs'),
    new SuggestionItem('title',   noopSuggestor, category: 'docs')
  ]
)

rootDocumentationSuggestor = new Suggestor(
  [
    new SuggestionItem('content', noopSuggestor, category: 'docs'),
    new SuggestionItem('title',   noopSuggestor, category: 'docs')
  ],
  null,
  { isList: true }
)

apiDefinitionSuggestor = new Suggestor(
  [
    new SuggestionItem('baseUri',           noopSuggestor,                 category: 'root'),
    new SuggestionItem('baseUriParameters', namedParameterGroupSuggestor,  category: 'parameters'),
    new SuggestionItem('documentation',     rootDocumentationSuggestor,    category: 'docs'),
    new SuggestionItem('mediaType',         noopSuggestor,                 category: 'root'),
    new SuggestionItem('protocols',         protocolsSuggestor,            category: 'root'),
    new SuggestionItem('resourceTypes',     resourceTypeGroupSuggestor,    category: 'traits and types'),
    new SuggestionItem('schemas',           noopSuggestor,                 category: 'schemas'),
    new SuggestionItem('securedBy',         noopSuggestor,                 category: 'security'),
    new SuggestionItem('securitySchemes',   securitySchemesGroupSuggestor, category: 'security'),
    new SuggestionItem('title',             noopSuggestor,                 category: 'root'),
    new SuggestionItem('traits',            traitGroupSuggestor,           category: 'traits and types'),
    new SuggestionItem('types',             namedParameterGroupSuggestor,  category: 'traits and types'),
    new SuggestionItem('uses',              noopSuggestor,                 category: 'docs'),
    new SuggestionItem('version',           noopSuggestor,                 category: 'root'),
    dynamicResource
  ],
  resourceFallback
)

librarySuggestor = new Suggestor(
  [
    new SuggestionItem('resourceTypes',     resourceTypeGroupSuggestor,    category: 'traits and types'),
    new SuggestionItem('schemas',           noopSuggestor,                 category: 'schemas'),
    new SuggestionItem('securitySchemes',   securitySchemesGroupSuggestor, category: 'security'),
    new SuggestionItem('traits',            traitGroupSuggestor,           category: 'traits and types'),
    new SuggestionItem('types',             namedParameterGroupSuggestor,  category: 'traits and types'),
    new SuggestionItem('usage',             noopSuggestor,                 category: 'docs'),
    new SuggestionItem('uses',              noopSuggestor,                 category: 'docs')
  ]
)

overlaySuggestor = new UnionSuggestor([
  apiDefinitionSuggestor,

  new Suggestor([
    new SuggestionItem('extends', noopSuggestor, category: 'docs'),
  ])
])

extensionSuggestor = new UnionSuggestor([
  apiDefinitionSuggestor,

  new Suggestor([
    new SuggestionItem('extends', noopSuggestor, category: 'docs'),
  ])
])

module.exports = {
  ApiDefinition:     apiDefinitionSuggestor,
  DataType:          namedParameterSuggestor,
  DocumentationItem: documentationItemSuggestor,
  Extension:         extensionSuggestor,
  Library:           librarySuggestor,
  Overlay:           overlaySuggestor,
  ResourceType:      resourceTypeSuggestor,
  SecurityScheme:    securitySchemesSuggestor,
  Trait:             traitSuggestor
}
