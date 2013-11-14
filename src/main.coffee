{typ3} = require './utils.coffee'

# Grammar representation objects
# TODO: Add required fields
class Tuple
  constructor: (@key, @value, @metadata={category: 'docs'}) ->
    if typ3(@metadata) == 'string'
      throw new Error("Metadata should be a dictionary")

    if not @key instanceof Node && typ3(@key) != 'string'
      throw "Key: '#{JSON.stringify(key)}' of type '#{typ3(key)}' must be an string"

class Alternatives then constructor: (@alternatives...) ->

class Multiple then constructor: (@element) ->

class PostposedExecution then constructor: (@f) ->

class Node

class Markdown extends Node

class Include extends Node

class JSONSchema extends Node

class Regex extends Node

class Integer extends Node

class Boolean extends Node

class XMLSchema extends Node

class StringNode extends Node

class ListNode extends Node

class ConstantString extends Node then constructor: (@value) ->

notImplemented = -> throw new Error('Not implemented')

class NodeMap
  @markdown: notImplemented
  @include: notImplemented
  @jsonSchema: notImplemented
  @regex: notImplemented
  @integer: notImplemented
  @boolean: notImplemented
  @xmlSchema: notImplemented
  @stringNode: notImplemented
  @listNode: notImplemented
  @constantString: notImplemented

# primitives
markdown = new Markdown()
include = new Include()
jsonSchema = new JSONSchema()
regex = new Regex()
integer = new Integer()
boolean = new Boolean()
xmlSchema = new XMLSchema()
stringNode = new StringNode()
listNode = new ListNode()

transversePrimitive = (nodeMap, node) ->
  if node == undefined
    throw new Error('Invalid root specified')

  switch node.constructor
    when Markdown
      nodeMap.markdown(node)
    when Include
      nodeMap.include(node)
    when JSONSchema
      nodeMap.jsonSchema(node)
    when Regex
      nodeMap.regex(node)
    when Integer
      nodeMap.integer(node)
    when Boolean
      nodeMap.boolean(node)
    when XMLSchema
      nodeMap.xmlSchema(node)
    when StringNode
      nodeMap.stringNode(node)
    when ListNode
      nodeMap.listNode(node)
    when ConstantString
      nodeMap.constantString(node)
    else
      throw "Invalid state: type '#{typ3(root)}' object '#{root}'"

class TreeMap
  @alternatives: notImplemented
  @tuple: notImplemented
  @multiple: notImplemented
  @postponedExecution: notImplemented
  @node: notImplemented

cache = []

transverse = (treeMap, root) ->

  if root == undefined
    throw new Error('Invalid root specified')

  for {cachedTree, cachedRoot, cachedResult} in cache
    if cachedTree is treeMap and cachedRoot is root
      return cachedResult

  result = switch root.constructor
    when Alternatives
      {alternatives} = root
      alternatives = (transverse(treeMap, alternative) for alternative in alternatives)
      treeMap.alternatives(root, alternatives)
    when Tuple
      {key, value} = root
      a = transverse(treeMap, key)
      b = transverse(treeMap, value)
      treeMap.tuple(root, a, b)
    when Multiple
      {element} = root
      m = transverse(treeMap, element)
      treeMap.multiple(root, m)
    when PostposedExecution
      {f} = root
      promise = new PostposedExecution( -> transverse(treeMap, f()))
      treeMap.postponedExecution(root, promise)
    else
      if root instanceof Node
        treeMap.node(root)
      else
        throw new Error("Invalid state: type '#{typ3(root)}' object '#{root}'")

  cache.push(
    cachedTree: treeMap
    cachedRoot: root
    cachedResult: result
  )

  return result

@transverse = transverse

# categories
rootCategory        = {category: 'root'}
docsCategory        = {category: 'docs'}
parametersCategory  = {category: 'parameters'}
schemasCategory     = {category: 'schemas'}
bodyCategory        = {category: 'body'}
responsesCategory   = {category: 'responses'}
methodsCategory     = {category: 'methods', canBeOptional: true}
securityCategory    = {category: 'security'}
traitsAndResourceTypesCategory = {category: 'traits and types'}
resourcesCategory   = {category: 'resources', id: 'resource'}

# Base Attributes
title   = new Tuple(new ConstantString('title'),  stringNode, rootCategory)
version = new Tuple(new ConstantString('version'),  stringNode, rootCategory)
baseUri = new Tuple(new ConstantString('baseUri'),  stringNode, rootCategory)
model   = new Tuple(stringNode,  jsonSchema, rootCategory)
schemas = new Tuple(new ConstantString('schemas'), new Multiple(model), rootCategory)

# Protocols
protocolsAlternatives = new Alternatives(new ConstantString('HTTP'), new ConstantString('HTTPS'))
protocols             = new Tuple(new ConstantString('protocols'), protocolsAlternatives, rootCategory)

# Parameter fields
name          = new Tuple(new ConstantString('displayName'), stringNode, docsCategory)
description   = new Tuple(new ConstantString('description'),  stringNode, docsCategory)
parameterType = new Tuple(new ConstantString('type'), new Alternatives(
                    new ConstantString('string'),
                    new ConstantString('number'),
                    new ConstantString('integer'),
                    new ConstantString('date'),
                    new ConstantString('boolean')), parametersCategory)
enum2         = new Tuple(new ConstantString('enum'), new Multiple(stringNode), parametersCategory)
pattern       = new Tuple(new ConstantString('pattern'),  regex, parametersCategory)
minLength     = new Tuple(new ConstantString('minLength'),  integer, parametersCategory)
maxLength     = new Tuple(new ConstantString('maxLength'),  integer, parametersCategory)
minimum       = new Tuple(new ConstantString('minimum'),  integer, parametersCategory)
maximum       = new Tuple(new ConstantString('maximum'),  integer, parametersCategory)
required      = new Tuple(new ConstantString('required'),  boolean, parametersCategory)
d3fault       = new Tuple(new ConstantString('default'),  stringNode, parametersCategory)
example       = new Tuple(new ConstantString('example'),  stringNode, docsCategory)

parameterProperties = [name, description, parameterType, enum2, pattern, minLength,  maxLength, maximum, minimum, required, d3fault, example]

parameterProperty = new Alternatives(parameterProperties...)

uriParameter      = new Tuple(stringNode,  new Multiple(parameterProperty), parametersCategory)
uriParameters     = new Tuple(new ConstantString('uriParameters'),  new Multiple(uriParameter), parametersCategory)
baseUriParameters = new Tuple(new ConstantString('baseUriParameters'),  new Multiple(uriParameter), parametersCategory)
mediaType         = new Tuple(new ConstantString('mediaType'), new Alternatives(stringNode, new Multiple(stringNode)), rootCategory)
chapter           = new Alternatives(title, new Tuple(new ConstantString('content'),  stringNode))
documentation     = new Tuple(new ConstantString('documentation'),  new Multiple(chapter), docsCategory)

# Header
header  = new Tuple(stringNode,  new Multiple(new Alternatives(parameterProperty)), parametersCategory)
headers = new Tuple(new ConstantString('headers'),  new Multiple(header), parametersCategory)

# Parameters
queryParameterDefinition  = new Tuple(stringNode,  new Multiple(new Alternatives(parameterProperty)), parametersCategory)
queryParameters           = new Tuple(new ConstantString('queryParameters'),  new Multiple(queryParameterDefinition), parametersCategory)
formParameterDefinition   = new Tuple(stringNode,  new Multiple(new Alternatives(parameterProperty)), parametersCategory)
formParameters            = new Tuple(new ConstantString('formParameters'), new Multiple(formParameterDefinition), parametersCategory)

# Body and MIME Type
bodySchema          = new Tuple(new ConstantString('schema'),  new Alternatives(xmlSchema, jsonSchema), schemasCategory)
mimeTypeParameters  = new Multiple(new Alternatives(bodySchema, example))
mimeType            = new Alternatives(
                        new Tuple(new ConstantString('application/x-www-form-urlencoded'), new Multiple(formParameters)),   new Tuple(new ConstantString('multipart/form-data'),  new Multiple(formParameters)),
                        new Tuple(new ConstantString('application/json'),  new Multiple(mimeTypeParameters))
                        new Tuple(new ConstantString('application/xml'),  new Multiple(mimeTypeParameters)),
                        new Tuple(stringNode,  new Multiple(mimeTypeParameters)))
body                = new Tuple(new ConstantString('body'),  new Multiple(mimeType), bodyCategory)

# Responses
responseCode  = new Tuple(new Multiple(integer), new Multiple(new Alternatives(body, description)), responsesCategory)
responses     = new Tuple(new ConstantString('responses'),  new Multiple(responseCode), responsesCategory)

# Secured by
securedBy = new Tuple(new ConstantString('securedBy'), listNode, securityCategory)

# Is
isTrait = new Tuple(new ConstantString('is'),  listNode, traitsAndResourceTypesCategory)

# Actions
actionDefinition = new Alternatives(
                                    description,
                                    baseUriParameters,
                                    headers,
                                    queryParameters,
                                    body,
                                    responses,
                                    securedBy,
                                    protocols,
                                    isTrait)
action = new Alternatives(
  ((new Tuple(new ConstantString(actionName), new Multiple(actionDefinition), methodsCategory)) \
      for actionName in [
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
      ])...)

# Type
type = new Tuple(new ConstantString('type'), stringNode, traitsAndResourceTypesCategory)

# Resource
postposedResource   = new Tuple(stringNode, new PostposedExecution( -> resourceDefinition),  resourcesCategory)
resourceDefinition  = new Alternatives(name, action, isTrait, type, postposedResource, securedBy,  uriParameters, baseUriParameters)
resource            = new Tuple(stringNode,  new Multiple(resourceDefinition),  resourcesCategory)

# Traits
traitsDefinition  = new Tuple(stringNode,  new Multiple(new Alternatives(name, description, baseUriParameters, headers, queryParameters, body, responses, securedBy, protocols)), traitsAndResourceTypesCategory)
traits            = new Tuple(new ConstantString('traits'), new Multiple(traitsDefinition), traitsAndResourceTypesCategory)

usage = new Tuple(new ConstantString('usage'), stringNode)

# Resource Types
resourceTypesDefinition = new Tuple(stringNode, new Multiple(new Alternatives(description, name, action,  isTrait, type, securedBy, baseUriParameters, uriParameters, usage)), traitsAndResourceTypesCategory)
resourceTypes           = new Tuple(new ConstantString('resourceTypes'), resourceTypesDefinition, traitsAndResourceTypesCategory)

# Security Schemes
settingAlternative = []
# OAuth 1.0
settingAlternative = settingAlternative.concat( [
  new Tuple(new ConstantString('requestTokenUri'), stringNode,      {category: 'security', type: ['OAuth 1.0']})
  new Tuple(new ConstantString('authorizationUri'), stringNode,     {category: 'security', type: ['OAuth 1.0', 'OAuth 2.0']})
  new Tuple(new ConstantString('tokenCredentialsUri'), stringNode,  {category: 'security', type: ['OAuth 1.0']})
])
# OAuth 2.0
settingAlternative = settingAlternative.concat( [
  new Tuple(new ConstantString('accessTokenUri'), stringNode,       {category: 'security', type: ['OAuth 2.0']})
  new Tuple(new ConstantString('authorizationGrants'), stringNode,  {category: 'security', type: ['OAuth 2.0']})
  new Tuple(new ConstantString('scopes'), stringNode,               {category: 'security', type: ['OAuth 2.0']})
])
# Other
settingAlternative = settingAlternative.concat( [
  new Tuple(stringNode, stringNode, {category: 'security'})
])

securityType              = new Tuple(new ConstantString('type'), new Alternatives(
                                          new ConstantString('OAuth 1.0'),
                                          new ConstantString('OAuth 2.0'),
                                          new ConstantString('Basic Authentication'),
                                          new ConstantString('Digest Authentication'), stringNode), securityCategory)
describedBy               = new Tuple(new ConstantString('describedBy'), new Alternatives(headers, queryParameters, responses), securityCategory)
settings                  = new Tuple(new ConstantString('settings'), new Alternatives(settingAlternative...))
securitySchemesDefinition = new Tuple(stringNode, new Multiple(new Alternatives(description, securityType, settings, describedBy)))
securitySchemes           = new Tuple(new ConstantString('securitySchemes'), securitySchemesDefinition, securityCategory)

# Root Element
rootElement = new Alternatives(
                                title,
                                version,
                                schemas,
                                baseUri,
                                baseUriParameters,
                                mediaType,
                                documentation,
                                resource,
                                traits,
                                resourceTypes,
                                securitySchemes,
                                securedBy,
                                protocols)
root = new Multiple(rootElement)

@root = root
@transversePrimitive = transversePrimitive
@TreeMap = TreeMap
@NodeMap = NodeMap
@integer = integer

