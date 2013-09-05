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

class PrimitiveAlternatives then constructor: (@alternatives...) ->

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
    when ConstantString
      nodeMap.constantString(node)
    else
      throw "Invalid state: type '#{typ3(root)}' object '#{root}'"

class TreeMap
  @alternatives: notImplemented
  @tuple: notImplemented
  @multiple: notImplemented
  @primitiveAlternatives: notImplemented
  @postponedExecution: notImplemented
  @nodeMap: notImplemented

transverse = (treeMap, root) ->

  if root == undefined
    throw new Error('Invalid root specified')

  switch
    when root instanceof Alternatives
      alternatives = (transverse(treeMap, alternative) for alternative in root.alternatives)
      treeMap.alternatives(root, alternatives)
    when root instanceof Tuple
      a = transverse(treeMap, root.key)
      b = transverse(treeMap, root.value)
      treeMap.tuple(root, a, b)
    when root instanceof Multiple
      m = transverse(treeMap, root.element)
      treeMap.multiple(root, m)
    when root instanceof PrimitiveAlternatives
      alternatives = (transverse(treeMap, alternative) for alternative in root.alternatives)
      treeMap.primitiveAlternatives(root, alternatives)
    when root instanceof PostposedExecution
      promise = new PostposedExecution(() -> transverse(treeMap, root.f()))
      treeMap.postponedExecution(root, promise)
    when root instanceof Node
      treeMap.node(root)
    else
      throw new Error('Invalid state: type ' + typ3(root) + ' object ' + root)

@transverse = transverse

# Base Attributes

title = new Tuple(new ConstantString('title'),  stringNode) 
version = new Tuple(new ConstantString('version'),  stringNode) 
baseUri = new Tuple(new ConstantString('baseUri'),  stringNode) 
model = new Tuple(stringNode,  jsonSchema) 
schemas = new Tuple(new ConstantString('schemas'), new Multiple(model))

# Parameter fields

name = new Tuple(new ConstantString('name'), stringNode)
description = new Tuple(new ConstantString('description'),  stringNode)
type = new Tuple(new ConstantString('type'), new PrimitiveAlternatives(new ConstantString('string'), new ConstantString('number'), new ConstantString('integer'), new ConstantString('date') ))
enum2 = new Tuple(new ConstantString('enum'), new Multiple(stringNode))
pattern = new Tuple(new ConstantString('pattern'),  regex) 
minLength = new Tuple(new ConstantString('minLength'),  integer) 
maxLength = new Tuple(new ConstantString('maxLength'),  integer) 
minimum = new Tuple(new ConstantString('minimum'),  integer) 
maximum = new Tuple(new ConstantString('maximum'),  integer) 
required = new Tuple(new ConstantString('required'),  boolean) 
d3fault = new Tuple(new ConstantString('default'),  stringNode) 
requires = new Tuple(new ConstantString('requires'),  new Multiple(stringNode)) 
provides = new Tuple(new ConstantString('provides'),  new Multiple(stringNode)) 
excludes = new Tuple(new ConstantString('excludes'),  new Multiple(stringNode)) 
parameterProperty = new Alternatives(name, description, type, enum2, pattern, minLength, 
  maxLength, maximum, minimum, required, d3fault, requires, excludes)

uriParameter = new Tuple(stringNode,  new Multiple(parameterProperty))
uriParameters = new Tuple(new ConstantString('uriParameters'),  new Multiple(uriParameter))
defaultMediaTypes = new Tuple(new ConstantString('defaultMediaTypes'),  
  new PrimitiveAlternatives(stringNode, new Multiple(stringNode)))
chapter = new Alternatives(new Tuple(new ConstantString('title'),  stringNode), new Tuple(new ConstantString('content'),  stringNode))
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

bodySchema = new Tuple(new ConstantString('schema'),  new PrimitiveAlternatives(xmlSchema, jsonSchema))
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

# Actions

actionDefinition = new Alternatives(summary, description, headers, queryParameters, 
  body, responses)
action = new Alternatives(((new Tuple(actionName, new Multiple(actionDefinition), {category: 'restful elements'})) for actionName in [new ConstantString('get'), new ConstantString('post'), new ConstantString('put'), new ConstantString('delete'), new ConstantString('head'), new ConstantString('path'), new ConstantString('options')])...)


# Use

use = new Tuple(new ConstantString('use'),  new Multiple(stringNode))

# Resource

postposedResource = new Tuple(stringNode, new PostposedExecution( -> resourceDefinition),
  {category: 'snippets', id: 'resource'})

resourceDefinition = new Alternatives(name, action, use, postposedResource)

resource = new Tuple(stringNode,  new Multiple(resourceDefinition),
  {category: 'snippets', id: 'resource'})

# Traits

traitDefinition = new Tuple(stringNode,  new Multiple(
  new Alternatives(description, provides, requires)))
trait = new Tuple(new ConstantString('traits'),  traitDefinition)
traits = new Multiple(trait)

# Root Element

rootElement = new Alternatives(title, version, schemas, baseUri, uriParameters, 
  defaultMediaTypes, documentation, resource, traits)
root = new Multiple(rootElement) 

@root = root
@transversePrimitive = transversePrimitive
@TreeMap = TreeMap
@NodeMap = NodeMap
@integer = integer

