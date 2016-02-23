suggestor = require '../src/suggestor'

# ---

SUPPORTED_HTTP_METHODS = [
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

SUPPORTED_MIME_TYPES = [ 'application/json', 'application/xml', 'application/x-www-form-urlencoded', 'multipart/form-data' ]

# ---

suggestRAML = (path, fragment = 'ApiDefinition') ->
  suggestor.suggestRAML path, '1.0', fragment

# ---

describe 'RAML 1.0',  ->
  describe 'SecurityScheme fragment', ->
    suggest = () ->
      suggestRAML [], 'SecurityScheme'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        'describedBy',
        'description',
        'settings',
        'type'
      ]

  describe 'Extension fragment', ->
    suggest = () ->
      suggestRAML [], 'Extension'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        '<resource>',
        'baseUri',
        'baseUriParameters',
        'documentation',
        'extends',
        'mediaType',
        'protocols',
        'resourceTypes',
        'schemas',
        'securedBy',
        'securitySchemes',
        'title',
        'traits',
        'types',
        'uses',
        'version'
      ]

  describe 'Overlay fragment', ->
    suggest = () ->
      suggestRAML [], 'Overlay'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        '<resource>',
        'baseUri',
        'baseUriParameters',
        'documentation',
        'extends',
        'mediaType',
        'protocols',
        'resourceTypes',
        'schemas',
        'securedBy',
        'securitySchemes',
        'title',
        'traits',
        'types',
        'uses',
        'version'
      ]

  describe 'Library fragment', ->
    suggest = () ->
      suggestRAML [], 'Library'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        'resourceTypes',
        'schemas',
        'securitySchemes',
        'traits',
        'types',
        'usage',
        'uses'
      ]

  describe 'DocumentationItem fragment', ->
    suggest = () ->
      suggestRAML [], 'DocumentationItem'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        'title',
        'content'
      ]

  describe 'ResourceType fragment', ->
    suggest = () ->
      suggestRAML [], 'ResourceType'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        'baseUriParameters',
        'connect',
        'delete',
        'description',
        'displayName',
        'get',
        'head',
        'is',
        'options',
        'patch',
        'post',
        'put',
        'securedBy',
        'trace',
        'type',
        'uriParameters',
        'usage'
      ]

  describe 'Trait fragment', ->
    suggest = () ->
      suggestRAML [], 'Trait'

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        'baseUriParameters',
        'body',
        'description',
        'displayName',
        'headers',
        'protocols',
        'queryParameters',
        'responses',
        'securedBy',
        'usage'
      ]

  describe 'DataType fragment', ->
    suggest = (path = []) ->
      suggestRAML path, 'DataType'

    it 'suggests expected properties for xml', ->
      {suggestions} = suggest(['xml'])
      suggestions.should.have.keys [
        'attribute',
        'name',
        'namespace',
        'prefix',
        'wrapped'
      ]

    it 'suggests expected properties', ->
      {suggestions} = suggest()
      suggestions.should.have.keys [
        'additionalProperties',
        'default',
        'description',
        'discriminator',
        'discriminatorValue',
        'displayName',
        'enum',
        'example',
        'examples',
        'facets',
        'fileTypes',
        'format',
        'items',
        'maximum',
        'maxItems',
        'maxLength',
        'maxProperties',
        'minimum',
        'minItems',
        'minLength',
        'minProperties',
        'multipleOf',
        'pattern',
        'properties',
        'required',
        'schema',
        'type',
        'uniqueItems',
        'xml'
      ]

  describe 'ApiDefinition fragment', ->
    it 'returns a <resource> suggestion that is dynamic', ->
      {suggestions} = suggestRAML []

      suggestions.should.include.key '<resource>'
      suggestions["<resource>"].metadata.dynamic.should.be.true

    it 'classifies title, version, baseUri, mediaType, and protocols as "root"', ->
      {suggestions} = suggestRAML []

      for key in ['title', 'version', 'baseUri', 'mediaType', 'protocols']
        suggestions[key].metadata.category.should.be.equal "root"

    it 'classifies schemas keys as "schemas"', ->
      {suggestions} = suggestRAML []

      suggestions.schemas.metadata.category.should.be.equal "schemas"

    it 'classifies root documentation keys as "docs"', ->
      {suggestions} = suggestRAML []

      suggestions.documentation.metadata.category.should.be.equal "docs"

      {suggestions} = suggestRAML ['documentation']

      suggestions.title.metadata.category.should.be.equal "docs"
      suggestions.content.metadata.category.should.be.equal "docs"

    it 'classifies all documentation keys as containers of a list', ->
      {metadata} = suggestRAML ['documentation']

      metadata.isList.should.be.equal true

    it 'classifies securedBy and securitySchemes keys as "security"', ->
      {suggestions} = suggestRAML []

      suggestions.securedBy.metadata.category.should.be.equal "security"
      suggestions.securitySchemes.metadata.category.should.be.equal "security"

    it 'classifies resourceTypes and traits as "traits and types"', ->
      {suggestions} = suggestRAML []

      suggestions.resourceTypes.metadata.category.should.be.equal "traits and types"
      suggestions.traits.metadata.category.should.be.equal "traits and types"

    it 'classifies baseUriParameters as parameters', ->
      {suggestions} = suggestRAML []

      suggestions.baseUriParameters.metadata.category.should.be.equal "parameters"

    describe 'Security Schemes', ->
      it 'offers expected suggestions', ->
        suggestion = suggestRAML ['securitySchemes', 'oauth_2_0']
        {suggestions} = suggestion
        suggestions.should.include.keys 'description', 'type', 'settings', 'describedBy'

        suggestions.description.metadata.category.should.be.equal 'docs'
        suggestions.type.metadata.category.should.be.equal 'security'
        suggestions.settings.metadata.category.should.be.equal 'security'
        suggestions.describedBy.metadata.category.should.be.equal 'security'

      it 'offers suggestions for describedBy', ->
        suggestion = suggestRAML ['securitySchemes', 'oauth_2_0', 'describedBy']
        {suggestions} = suggestion
        suggestions.should.include.keys 'headers', 'queryParameters', 'responses'
        suggestions.queryParameters.metadata.category.should.be.equal 'parameters'
        suggestions.headers.metadata.category.should.be.equal 'parameters'
        suggestions.responses.metadata.category.should.be.equal 'responses'


      it 'supports "type" suggestions', ->
        suggestion = suggestRAML ['securitySchemes', 'oauth_2_0', 'type']
        {suggestions} = suggestion
        for key in ['OAuth 1.0', 'OAuth 2.0', 'Basic Authentication',
              'Digest Authentication']

          suggestions.should.include.key key
          suggestions[key].metadata.category.should.be.equal 'security'

      it 'suggests keys for the "settings" attribute', ->
        suggestion = suggestRAML ['securitySchemes', 'oauth_2_0', 'settings']
        {suggestions} = suggestion

        for key in ['requestTokenUri', 'authorizationUri', 'tokenCredentialsUri',
          'accessTokenUri', 'authorizationGrants', 'scopes']

          suggestions.should.include.key key
          suggestions[key].metadata.category.should.be.equal 'security'

        suggestions.should.include.keys

    describe 'Resource Types', ->
      it 'returns no suggestions in the array', ->
        {suggestions} = suggestRAML ['resourceTypes']
        suggestions.should.be.empty

      it 'contains all the properties found in a resource suggestion except "<resource>"', ->
        {suggestions: resourceTypeSuggestion} = suggestRAML ['resourceTypes', 'collection']
        {suggestions: resourceSuggestions} = suggestRAML ['/hello']

        delete resourceSuggestions["<resource>"]

        resourceTypeSuggestion.should.include.keys (Object.keys resourceSuggestions)

      it 'also includes the usage property', ->
        {suggestions} = suggestRAML ['resourceTypes', 'collection']
        suggestions.should.include.key 'usage'
        suggestions.usage.metadata.category.should.be.equal 'docs'

      it 'supports nesting inside properties', ->
        {suggestions} = suggestRAML ['resourceTypes', 'collection', 'get']
        {suggestions: methodSuggestions} = suggestRAML ['/hello', 'get']
        suggestions.should.include.keys (Object.keys methodSuggestions)

        {suggestions} = suggestRAML ['resourceTypes', 'collection', 'get', 'responses', '200']
        suggestions.should.include.keys 'description'

      it 'does not allow nesting of resources', ->
        {suggestions} = suggestRAML ['resourceTypes', 'collection', '/hello']
        suggestions.should.be.empty

      for optionalProperty in SUPPORTED_HTTP_METHODS
        do (optionalProperty) =>
          it "suggests the same properties as optional '#{optionalProperty}' property", ->
            {suggestions: suggestions1} = suggestRAML ['resourceTypes', 'resourceType1', optionalProperty + '?']
            {suggestions: suggestions2} = suggestRAML ['resourceTypes', 'resourceType2', optionalProperty      ]
            suggestions1.should.be.deep.equal(suggestions2)

      for optionalProperty in ['baseUriParameters', 'uriParameters']
        do (optionalProperty) =>
          it "suggests the same properties as optional '#{optionalProperty}' property", ->
            {suggestions: suggestions1} = suggestRAML ['resourceTypes', 'resourceType1', optionalProperty + '?', 'property']
            {suggestions: suggestions2} = suggestRAML ['resourceTypes', 'resourceType2', optionalProperty      , 'property']
            suggestions1.should.be.deep.equal(suggestions2)

    describe 'Traits', ->
      it 'returns no suggestions in the array', ->
        {suggestions} = suggestRAML ['traits']
        suggestions.should.be.empty

      it 'contains all the properties found in a method suggestion except "is"', ->
        {suggestions: traitSuggestions} = suggestRAML ['traits', 'traitA']
        {suggestions: methodSuggestions} = suggestRAML ['/', 'get']

        delete methodSuggestions.is
        traitSuggestions.should.include.keys(Object.keys(methodSuggestions))
        traitSuggestions.should.not.include.key 'is'

      it 'also contains "usage" and "displayName" properties', ->
        {suggestions} = suggestRAML ['traits', 'traitA']
        for key in ['usage', 'displayName', 'description']
          suggestions.should.include.key key
          suggestions[key].metadata.category.should.be.equal 'docs'

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
          suggestions.should.include.keys 'displayName', 'baseUriParameters', 'description', 'is', 'type', 'securedBy', 'uriParameters'
          suggestions.should.include.keys(SUPPORTED_HTTP_METHODS)

          for method in SUPPORTED_HTTP_METHODS
            suggestions[method].metadata.category.should.be.equal 'methods'

          for key in ['displayName', 'description']
            suggestions[key].metadata.category.should.be.equal 'docs'

          for key in ['uriParameters', 'baseUriParameters']
            suggestions[key].metadata.category.should.be.equal 'parameters'

          for key in ['is', 'type']
            suggestions[key].metadata.category.should.be.equal 'traits and types'

          for key in ['securedBy']
            suggestions[key].metadata.category.should.be.equal 'security'

          suggestions.should.not.include.key 'usage'

      it 'returns a <resource> suggestion that is dynamic', ->
        {suggestions} = suggestRAML ['/hello']

        suggestions.should.include.key '<resource>'
        suggestions["<resource>"].metadata.dynamic.should.be.true

    describe 'Methods', ->
      it 'offers expected suggestions', ->
        {suggestions} = suggestRAML ['/hello', 'get']

        suggestions.should.include.keys 'description', 'protocols', 'is', 'body', 'headers', 'securedBy', 'responses', 'queryParameters', 'baseUriParameters'
        suggestions.should.not.include.key 'usage'

        suggestions.protocols.metadata.category.should.be.equal 'root'
        suggestions.is.metadata.category.should.be.equal 'traits and types'
        suggestions.body.metadata.category.should.be.equal 'body'
        suggestions.securedBy.metadata.category.should.be.equal 'security'
        suggestions.responses.metadata.category.should.be.equal 'responses'
        suggestions.headers.metadata.category.should.be.equal 'parameters'
        suggestions.queryParameters.metadata.category.should.be.equal 'parameters'
        suggestions.baseUriParameters.metadata.category.should.be.equal 'parameters'

      describe 'body', ->
        it 'contains common mime-types as sublevel suggestions (RT-81)', ->
          {suggestions} = suggestRAML ['/hello', 'get', 'body']

          suggestions.should.include.keys SUPPORTED_MIME_TYPES

          for mimeType in SUPPORTED_MIME_TYPES
            suggestions[mimeType].metadata.category.should.be.equal 'body'

    describe 'Named Parameters', ->
      expectedKeys = ['displayName', 'description', 'type', 'enum', 'pattern', 'minLength', 'maxLength', 'maximum', 'minimum', 'required', 'default', 'example']

      it 'categorizes displayName, description, and example as docs', ->
        {suggestions} = suggestRAML ['/resource', 'get', 'queryParameters', 'someName']

        for key in ['displayName', 'description', 'example']
          suggestions[key].metadata.category.should.be.equal 'docs'

      it 'categorizes all other keys as parameters', ->
        {suggestions} = suggestRAML ['/resource', 'get', 'queryParameters', 'someName']

        for key in expectedKeys
          unless key in ['displayName', 'description', 'example']
            suggestions[key].metadata.category.should.be.equal 'parameters'

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

        suggestions.body.metadata.category.should.be.equal 'responses'
        suggestions.description.metadata.category.should.be.equal 'docs'

        {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses', '200', 'body']
        suggestions.should.include.keys SUPPORTED_MIME_TYPES

        for mimeType in SUPPORTED_MIME_TYPES
          suggestions[mimeType].metadata.category.should.be.equal 'body'

        {suggestions} = suggestRAML ['/hello', '/bye', 'get', 'responses', '200', 'body', 'application/json']
        suggestions.should.include.keys 'schema', 'example'

        suggestions.schema.metadata.category.should.be.equal 'schemas'
        suggestions.example.metadata.category.should.be.equal 'docs'

      it 'supports arrays as keys', ->
        arraysAsKeysSuggestion = suggestRAML ['/foo', 'get', 'responses', '[200, 210]']
        suggestion = suggestRAML ['/foo', 'get', 'responses', '200']

        arraysAsKeysSuggestion.suggestions.should.include.keys (Object.keys suggestion.suggestions)

    describe 'Protocols', ->
      it 'suggests both HTTP and HTTPS inside a "protocols" key inside an action', ->
        {suggestions} = suggestRAML [ '/resource', 'get', 'protocols' ]
        suggestions.should.include.keys 'HTTP', 'HTTPS'

      it 'suggests both HTTP and HTTPS inside a "protocols" key in the root element, both of which are marked as text nodes', ->
        {suggestions} = suggestRAML [ 'protocols' ]
        suggestions.should.include.keys 'HTTP', 'HTTPS'
        suggestions.HTTP.metadata.isText.should.be.equal(true);
        suggestions.HTTPS.metadata.isText.should.be.equal(true);

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
