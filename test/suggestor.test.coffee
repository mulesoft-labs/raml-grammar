suggestor   = require '../src/suggestor'
suggestor08 = require '../src/suggestor08'
suggestor10 = require '../src/suggestor10'

# ---

describe 'suggestor', ->
  describe '#suggestRAML', ->
    it 'should support path as empty array, null, and undefined', ->
      for path in [[], null, undefined]
        (suggestor.suggestRAML path).should.have.keys ['suggestions', 'metadata']

    describe 'by default', ->
      it 'should use RAML 0.8 grammar and ApiDefinition fragment', ->
        (suggestor.suggestRAML []).should.have.deep.property('suggestions.<resource>')
        (suggestor.suggestRAML []).should.not.have.deep.property('suggestions.types')

    describe 'when version is 0.8', ->
      it 'should use RAML 0.8 grammar and ApiDefinition fragment', ->
        (suggestor.suggestRAML [], '0.8').should.have.deep.property('suggestions.<resource>')
        (suggestor.suggestRAML [], '0.8').should.not.have.deep.property('suggestions.types')

      describe 'when fragment is not supported', ->
        it 'should throw exception', ->
          (->
            suggestor.suggestRAML([], '0.8', 'UknownFragment')
          ).should.throw('unsupported fragment: UknownFragment')

    describe 'when version is 1.0', ->
      it 'should use RAML 1.0 grammar and ApiDefinition fragment', ->
        (suggestor.suggestRAML [], '1.0').should.have.deep.property('suggestions.types')

      describe 'when fragment is not supported', ->
        it 'should throw exception', ->
          (->
            suggestor.suggestRAML([], '1.0', 'UknownFragment')
          ).should.throw('unsupported fragment: UknownFragment')

    describe 'when version is not supported', ->
      it 'should throw exception', ->
        (->
          suggestor.suggestRAML([], '0.7')
        ).should.throw('unsupported version: 0.7')
