{noopSuggestor} = require './suggestorXX'
suggestor08     = require './suggestor08'
suggestor10     = require './suggestor10'

# ---

module.exports.suggestRAML = (path = [], version = '0.8', fragment = 'ApiDefinition') ->
  suggestor = {'0.8': suggestor08, '1.0': suggestor10}[version]
  unless suggestor
    throw new Error('unsupported version: ' + version)

  suggestor = suggestor[fragment]
  unless suggestor
    throw new Error('unsupported fragment: ' + fragment)

  while suggestor and path.length
    suggestor = suggestor.suggestorFor path.shift()

  unless suggestor
    suggestor = noopSuggestor

  return {
    suggestions: suggestor.suggestions(),
    metadata:    suggestor.metadata
  }
