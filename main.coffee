# TODO: required fields
#
#

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

typ3 = (obj) ->
  if obj == undefined or obj == null
    return String obj
  classToType = new Object
  for name in "Boolean Number String Function Array Date RegExp".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()
  myClass = Object.prototype.toString.call obj
  if myClass of classToType
    return classToType[myClass]
  return "object"

class Tuple
  constructor: (@key, @value) ->
    if typ3(@key) != 'string'
      throw "Key: '#{JSON.stringify(key)}' of type '#{typ3(key)}' must be an string"

class Alternatives
  constructor: (@alternatives...) ->

class PrimitiveAlternatives
  constructor: (@alternatives...) ->

class Multiple
  constructor: (@element) ->

# primitives
markdown = '<markdown>'
include = '<include>'
string = '<string>'
path = '<path>'
jsonSchema = '<jsonSchema>'
regex = '<regex>'
integer = '<int>'
boolean = '<bool>'
xmlSchema = '<xmlSchema>'

Markdown = new Alternatives(markdown, include)
path = string 
include = include 
#String = new Alternatives(string, include )
title = new Tuple('title',  string) 
version = new Tuple('version',  string) 
model = new Tuple(string,  jsonSchema) 
schemas = new Tuple('schemas', new Multiple(model))
baseUri = new Tuple('baseUri',  string) 
name = new Tuple('name', string)
description = new Tuple('description',  string)
type = new Tuple('type', new PrimitiveAlternatives('string', 'number', 'integer', 'date' ))
enum2 = new Tuple('enum', new Multiple(string))
pattern = new Tuple('pattern',  regex) 
minLength = new Tuple('minLength',  integer) 
maxLength = new Tuple('maxLength',  integer) 
minimum = new Tuple('minimum',  integer) 
maximum = new Tuple('maximum',  integer) 
required = new Tuple('required',  boolean) 
d3fault = new Tuple('default',  string) 
requires = new Tuple('requires',  new Multiple(string)) 
provides = new Tuple('provides',  new Multiple(string)) 
excludes = new Tuple('excludes',  new Multiple(string)) 
parameterProperty = new Alternatives(name, description, type, enum2, pattern, minLength, maxLength, maximum, minimum, required, d3fault, requires, excludes)
uriParameter = new Tuple(string,  new Multiple(parameterProperty))
uriParameters = new Tuple('uriParameters',  new Multiple(uriParameter))
defaultMediaTypes = new Tuple('defaultMediaTypes',  new PrimitiveAlternatives(string, new Multiple(string)))
chapter = new Alternatives(new Tuple('title',  string), new Tuple('content',  string))
documentation = new Tuple('documentation',  new Multiple(chapter))
summary = new Tuple('summary',  string)
example = new Tuple('example',  string)
header = new Tuple(string,  new Multiple(new Alternatives(parameterProperty, example)))
headers = new Tuple('headers',  new Multiple(header))
queryParameterDefinition = new Tuple(string,  new Multiple(new Alternatives(parameterProperty, example)))
queryParameters = new Tuple('queryParameters',  new Multiple(queryParameterDefinition))
formParameters = new Tuple('formParameters',  new Multiple(new Alternatives(parameterProperty, example)))
bodySchema = new Tuple('schema',  new PrimitiveAlternatives(xmlSchema, jsonSchema))
mimeTypeParameters = new Multiple(new Alternatives(bodySchema, example))
mimeType = new Alternatives(new Tuple('application/x-www-form-urlencoded',  new Multiple(formParameters)),
  new Tuple('multipart/form-data',  new Multiple(formParameters)),  new Tuple(string,  new Multiple(mimeTypeParameters)))
body = new Tuple('body',  new Multiple(mimeType))
responseCode = new Tuple(integer, new Multiple(integer),  new Multiple(new Alternatives(body, description)))
responses = new Tuple('responses',  new Multiple(responseCode))
actionDefinition = new Alternatives(summary, description, headers, queryParameters, body, responses)

#action = new Tuple(new Alternatives('get', 'post', 'put', 'delete', 'head', 'patch', 'options'),  new Multiple(actionDefinition))
action = new Alternatives(((new Tuple(actionName, new Multiple(actionDefinition))) for actionName in ['get', 'post', 'put', 'delete', 'head', 'path', 'options'])...)
use = new Tuple('use',  new Multiple(string))
resourceDefinition = new Alternatives(name, action, use) #add resource
resource = new Tuple(string,  new Multiple(resourceDefinition))
traitDefinition = new Tuple(string,  new Multiple(new Alternatives(description, provides, requires)))
trait = new Tuple('traits',  traitDefinition)
traits = new Multiple(trait)
rootElement = new Alternatives(title, version, schemas, baseUri, uriParameters, defaultMediaTypes, documentation, resource, traits)
root = new Multiple(rootElement) 

transverse = (root, fa, ft, fm, fpa) ->
  switch
    when root instanceof Alternatives
      alternatives = (transverse(alternative, fa, ft, fm, fpa) for alternative in root.alternatives)
      fa(root, alternatives)
    when root instanceof Tuple
      a = transverse(root.key, fa, ft, fm, fpa)
      b = transverse(root.value, fa, ft, fm, fpa)
      ft(root, a, b)
    when root instanceof Multiple
      m = transverse(root.element, fa, ft, fm, fpa)
      fm(root, m)
    when root instanceof PrimitiveAlternatives
      alternatives = (transverse(alternatives, fa, ft, fm, fpa) for alternatives in root.alternatives)
      fpa(root, alternatives)

    when typeof root == 'string' then root
    else throw 'Invalid state: ' + typ3(root) + ' ' + root

i = 0

getSpaces = () -> (' ' for num in [1..i]).join('')

a = (root, alternatives) -> 
  i = i + 1
  res =  '(' + getSpaces() + alternatives.join(' | ') + ')'
  i = i - 1
  res
t = (root, key, value) -> 
  i = i + 1
  res = '(' + key + ': ' + value + ')'
  i = i - 1
  res
m = (root, element) -> 
  i = i + 1
  res = '[' + getSpaces() + element + ']'
  i = i - 1
  res

pa = (root, element) ->
  i = i + 1
  res =  '(' + getSpaces() + alternatives.join(' | ') + ')'
  i = i - 1
  res


# console.log(transverse(root, a, t, m))

m = {}

curr = m

am = (root, alternatives) ->
  d = {}
  for alternative in alternatives
    for key, value of alternative
      d[key] = value
  d

tm = (root, key, value) ->
  d = {}
  kind = typ3(key)
  switch kind
    when 'Array'
      for k in key
        switch typ3(k)
          when 'string'
            d[k] = value
          else 
            throw k
    when 'object'
      for k in key
        switch typ3(k)
          when 'string'
            d[k] = value
          else
            throw k
    else 
      d[key] = value
  d

mm = (root, element) ->
  element
  
pam = (root, alternatives) ->
  alternatives

map = transverse(root, am, tm, mm, pam)

suggest = (root, index,  path...) ->
  key = path[index]

  if not path[index]?
    return root
    
  val = root[key]

  if not val?
    val = root['<string>']
  suggest(val, index + 1, path...)

console.log suggest(map, 0, '/lala')


#repl = require('repl')
#
#dir = map
#
#stack = []
#
#repl.start(
#  prompt: '>',
#  input: process.stdin,
#  output: process.stdout,
#  eval: (cmd, ctx, filename, callback) ->
#    cmd = cmd.replace(/\n|\(|\)/g, '')
#
#    if cmd == 'up'
#      if stack.length == 0
#        console.log 'Top level reached'
#        return
#      dir = stack.pop()
#      console.log dir
#      return
#
#    stack.push(dir)
#    tmp = dir[cmd]
#    if tmp?
#      dir = tmp
#    else
#      dir = dir['<string>']
#
#    callback(JSON.stringify(dir))
#)
#
#
