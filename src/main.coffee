{typ3} = require './utils.coffee'

# Grammar representation objects
# TODO: Add required fields
class Tuple
  constructor: (@key, @value, @metadata={category: 'raml specification'}) ->
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

  for elem in cache
    {cachedTree, cachedRoot, cachedResult} = elem
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

# Base Attributes

title = new Tuple(new ConstantString('title'),  stringNode) 
version = new Tuple(new ConstantString('version'),  stringNode) 
baseUri = new Tuple(new ConstantString('baseUri'),  stringNode) 
model = new Tuple(stringNode,  jsonSchema) 
schemas = new Tuple(new ConstantString('schemas'), new Multiple(model))

# Parameter fields

name = new Tuple(new ConstantString('displayName'), stringNode)
description = new Tuple(new ConstantString('description'),  stringNode)
parameterType = new Tuple(new ConstantString('type'), new Alternatives(new ConstantString('string'), new ConstantString('number'), new ConstantString('integer'), new ConstantString('date'),
  new ConstantString('boolean')))
enum2 = new Tuple(new ConstantString('enum'), new Multiple(stringNode))
pattern = new Tuple(new ConstantString('pattern'),  regex) 
minLength = new Tuple(new ConstantString('minLength'),  integer) 
maxLength = new Tuple(new ConstantString('maxLength'),  integer) 
minimum = new Tuple(new ConstantString('minimum'),  integer) 
maximum = new Tuple(new ConstantString('maximum'),  integer) 
required = new Tuple(new ConstantString('required'),  boolean) 
d3fault = new Tuple(new ConstantString('default'),  stringNode) 
parameterProperty = new Alternatives(name, description, parameterType, enum2, pattern, minLength, 
  maxLength, maximum, minimum, required, d3fault)

uriParameter = new Tuple(stringNode,  new Multiple(parameterProperty))
uriParameters = new Tuple(new ConstantString('uriParameters'),  new Multiple(uriParameter))
defaultMediaTypes = new Tuple(new ConstantString('defaultMediaTypes'),  
  new Alternatives(stringNode, new Multiple(stringNode)))
chapter = new Alternatives(title, new Tuple(new ConstantString('content'),  stringNode))
documentation = new Tuple(new ConstantString('documentation'),  new Multiple(chapter))
summary = new Tuple(new ConstantString('summary'),  stringNode)
example = new Tuple(new ConstantString('example'),  stringNode)

# Header

header = new Tuple(stringNode,  new Multiple(new Alternatives(parameterProperty, example)))
headers = new Tuple(new ConstantString('headers'),  new Multiple(header))

# Parameters

queryParameterDefinition = new Tuple(stringNode,  
  new Multiple(new Alternatives(parameterProperty, example)))
queryParameters = new Tuple(new ConstantString('queryParameters'),  new Multiple(queryParameterDefinition))
formParameters = new Tuple(new ConstantString('formParameters'),  
  new Multiple(new Alternatives(parameterProperty, example)))


# Body and MIME Type

bodySchema = new Tuple(new ConstantString('schema'),  new Alternatives(xmlSchema, jsonSchema))
mimeTypeParameters = new Multiple(new Alternatives(bodySchema, example))
mimeType = new Alternatives(
  new Tuple(new ConstantString('application/x-www-form-urlencoded'), new Multiple(formParameters)),   new Tuple(new ConstantString('multipart/form-data'),  new Multiple(formParameters)),  
  new Tuple(new ConstantString('application/json'),  new Multiple(mimeTypeParameters))
  new Tuple(new ConstantString('application/xml'),  new Multiple(mimeTypeParameters)),
  new Tuple(stringNode,  new Multiple(mimeTypeParameters)))
body = new Tuple(new ConstantString('body'),  new Multiple(mimeType))

# Responses

responseCode = new Tuple(new Multiple(integer), 
  new Multiple(new Alternatives(body, description)))
responses = new Tuple(new ConstantString('responses'),  new Multiple(responseCode))

# Secured by

securedBy = new Tuple(new ConstantString('securedBy'), listNode)

# Actions

actionDefinition = new Alternatives(summary, description, headers, queryParameters, 
  body, responses, securedBy)
action = new Alternatives(((new Tuple(actionName, new Multiple(actionDefinition), {category: 'restful elements'})) for actionName in [new ConstantString('get'), new ConstantString('post'), new ConstantString('put'), new ConstantString('delete'), new ConstantString('head'), new ConstantString('path'), new ConstantString('options')])...)


# Is

isTrait = new Tuple(new ConstantString('is'),  listNode)

# Type

type = new Tuple(new ConstantString('type'), stringNode)

# Resource

postposedResource = new Tuple(stringNode, new PostposedExecution( -> resourceDefinition),
  {category: 'snippets', id: 'resource'})

resourceDefinition = new Alternatives(name, action, isTrait, type, postposedResource, securedBy)

resource = new Tuple(stringNode,  new Multiple(resourceDefinition),
  {category: 'snippets', id: 'resource'})

# Traits

traitsDefinition = new Tuple(stringNode,  new Multiple(
  new Alternatives(name, summary, description, headers, queryParameters, body, responses, securedBy)))
traits = new Tuple(new ConstantString('traits'), new Multiple(traitsDefinition))

# Resource Types

resourceTypesDefinition = new Tuple(stringNode, new Multiple(new Alternatives(summary, description, name, action,
  isTrait, type, securedBy)))
resourceTypes = new Tuple(new ConstantString('resourceTypes'), resourceTypesDefinition)

# Security Schemes
securityType = new Tuple(new ConstantString('type'), new Alternatives(
  new ConstantString('OAuth 1.0'), new ConstantString('OAuth 2.0'),
  new ConstantString('Basic Authentication'), 
  new ConstantString('Digest Authentication'), stringNode), {category: 'security'})
describedBy = new Tuple(new ConstantString('describedBy'), 
  new Alternatives(headers, queryParameters, responses), {category: 'security'})
settings = new Tuple(new ConstantString('settings'), new Alternatives(

  # OAuth 1.0
  new Tuple(new ConstantString('requestTokenUri'), stringNode, {category: 'security', type: ['OAuth 1.0']}),
  new Tuple(new ConstantString('authorizationUri'), stringNode, 
    {category: 'security', type: ['OAuth 1.0', 'OAuth 2.0']}),
  new Tuple(new ConstantString('tokenCredentialsUri'), stringNode, {category: 'security', type: ['OAuth 1.0']})
  
  # OAuth 2.0
  new Tuple(new ConstantString('accessTokenUri'), stringNode, {category: 'security', type: ['OAuth 2.0']})
  new Tuple(new ConstantString('authorizationGrants'), stringNode, {category: 'security', type: ['OAuth 2.0']})
  new Tuple(new ConstantString('scopes'), stringNode, {category: 'security', type: ['OAuth 2.0']})

  # Other
  new Tuple(stringNode, stringNode, {category: 'security'})
  
  ))
securitySchemesDefinition = new Tuple(stringNode, new Multiple(new Alternatives(
  description, securityType, settings, describedBy)))
securitySchemes = new Tuple(new ConstantString('securitySchemes'), securitySchemesDefinition)

# Root Element

rootElement = new Alternatives(title, version, schemas, baseUri, uriParameters, 
  defaultMediaTypes, documentation, resource, traits, resourceTypes, securitySchemes, securedBy)
root = new Multiple(rootElement)

@root = root
@transversePrimitive = transversePrimitive
@TreeMap = TreeMap
@NodeMap = NodeMap
@integer = integer

